// Copyright (c) 2018, 2022, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

package oracle.kubernetes.operator.work;

import java.util.Collection;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.function.UnaryOperator;
import java.util.stream.Collectors;

import oracle.kubernetes.common.logging.MessageKeys;
import oracle.kubernetes.operator.logging.LoggingFacade;
import oracle.kubernetes.operator.logging.LoggingFactory;

/**
 * ContainerResolver based on {@link ThreadLocal}.
 *
 * <p>The ThreadLocalContainerResolver is the default implementation available from the
 * ContainerResolver using {@link ContainerResolver#getDefault()}. Code sections that run with a
 * Container must use the following pattern:
 *
 * <pre>
 * public void m() {
 *   Container old = ContainerResolver.getDefault().enterContainer(myContainer);
 *   try {
 *     // ... method body
 *   } finally {
 *     ContainerResolver.getDefault().exitContainer(old);
 *   }
 * }
 * </pre>
 */
public class ThreadLocalContainerResolver extends ContainerResolver {
  private static final LoggingFacade LOGGER = LoggingFactory.getLogger("Operator", "Operator");

  private final ThreadLocal<Container> containerThreadLocal =
      ThreadLocal.withInitial(() -> Container.NONE);

  public Container getContainer() {
    return containerThreadLocal.get();
  }

  /**
   * Enters container.
   *
   * @param container Container to set
   * @return Previous container; must be remembered and passed to exitContainer
   */
  public Container enterContainer(Container container) {
    Container old = containerThreadLocal.get();
    containerThreadLocal.set(container);
    return old;
  }

  /**
   * Exits container.
   *
   * @param old Container returned from enterContainer
   */
  public void exitContainer(Container old) {
    if (old == null) {
      containerThreadLocal.remove();
    } else {
      containerThreadLocal.set(old);
    }
  }

  ScheduledExecutorService wrapExecutor(
      final Container container, final ScheduledExecutorService ex) {
    if (ex == null) {
      return null;
    }

    UnaryOperator<Runnable> wrap =
        x -> () -> {
          Container old = enterContainer(container);
          try {
            x.run();
          } catch (RuntimeException | Error runtime) {
            LOGGER.severe(MessageKeys.EXCEPTION, runtime);
            throw runtime;
          } catch (Throwable throwable) {
            LOGGER.severe(MessageKeys.EXCEPTION, throwable);
            throw new RuntimeException(throwable);
          } finally {
            exitContainer(old);
          }
        };

    UnaryOperator<Callable<?>> wrap2 =
        x -> () -> {
          Container old = enterContainer(container);
          try {
            return x.call();
          } catch (RuntimeException | Error runtime) {
            LOGGER.severe(MessageKeys.EXCEPTION, runtime);
            throw runtime;
          } catch (Throwable throwable) {
            LOGGER.severe(MessageKeys.EXCEPTION, throwable);
            throw new RuntimeException(throwable);
          } finally {
            exitContainer(old);
          }
        };

    UnaryOperator<Collection<? extends Callable<?>>> wrap2c =
        x -> x.stream().map(wrap2).collect(Collectors.toList());

    return new ScheduledExecutorService() {

      @Override
      public boolean awaitTermination(long timeout, TimeUnit unit) throws InterruptedException {
        return ex.awaitTermination(timeout, unit);
      }

      @SuppressWarnings({"rawtypes", "unchecked"})
      @Override
      public <T> List<Future<T>> invokeAll(Collection<? extends Callable<T>> tasks)
          throws InterruptedException {
        return ex.invokeAll((List) wrap2c.apply(tasks));
      }

      @SuppressWarnings({"rawtypes", "unchecked"})
      @Override
      public <T> List<Future<T>> invokeAll(
          Collection<? extends Callable<T>> tasks, long timeout, TimeUnit unit)
          throws InterruptedException {
        return ex.invokeAll((List) wrap2c.apply(tasks), timeout, unit);
      }

      @SuppressWarnings({"rawtypes", "unchecked"})
      @Override
      public <T> T invokeAny(Collection<? extends Callable<T>> tasks)
          throws InterruptedException, ExecutionException {
        return (T) ex.invokeAny((List) wrap2c.apply(tasks));
      }

      @SuppressWarnings({"rawtypes", "unchecked"})
      @Override
      public <T> T invokeAny(Collection<? extends Callable<T>> tasks, long timeout, TimeUnit unit)
          throws InterruptedException, ExecutionException, TimeoutException {
        return (T) ex.invokeAny((List) wrap2c.apply(tasks), timeout, unit);
      }

      @Override
      public boolean isShutdown() {
        return ex.isShutdown();
      }

      @Override
      public boolean isTerminated() {
        return ex.isTerminated();
      }

      @Override
      public void shutdown() {
        ex.shutdown();
      }

      @Override
      public List<Runnable> shutdownNow() {
        return ex.shutdownNow();
      }

      @SuppressWarnings({"rawtypes", "unchecked"})
      @Override
      public <T> Future<T> submit(Callable<T> task) {
        return (Future) ex.submit(wrap2.apply(task));
      }

      @Override
      public Future<?> submit(Runnable task) {
        return ex.submit(wrap.apply(task));
      }

      @Override
      public <T> Future<T> submit(Runnable task, T result) {
        return ex.submit(wrap.apply(task), result);
      }

      @Override
      public void execute(Runnable command) {
        ex.execute(wrap.apply(command));
      }

      @Override
      public ScheduledFuture<?> schedule(Runnable command, long delay, TimeUnit unit) {
        return ex.schedule(wrap.apply(command), delay, unit);
      }

      @SuppressWarnings({"rawtypes", "unchecked"})
      @Override
      public <V> ScheduledFuture<V> schedule(Callable<V> callable, long delay, TimeUnit unit) {
        return ex.schedule((Callable) wrap2.apply(callable), delay, unit);
      }

      @Override
      public ScheduledFuture<?> scheduleAtFixedRate(
          Runnable command, long initialDelay, long period, TimeUnit unit) {
        return ex.scheduleAtFixedRate(wrap.apply(command), initialDelay, period, unit);
      }

      @Override
      public ScheduledFuture<?> scheduleWithFixedDelay(
          Runnable command, long initialDelay, long delay, TimeUnit unit) {
        return ex.scheduleWithFixedDelay(wrap.apply(command), initialDelay, delay, unit);
      }
    };
  }
}
