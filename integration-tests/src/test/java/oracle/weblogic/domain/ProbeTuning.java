// Copyright (c) 2020, 2021, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

package oracle.weblogic.domain;

import io.swagger.annotations.ApiModelProperty;
import org.apache.commons.lang3.builder.EqualsBuilder;
import org.apache.commons.lang3.builder.HashCodeBuilder;
import org.apache.commons.lang3.builder.ToStringBuilder;

public class ProbeTuning {

  @ApiModelProperty("The number of seconds before the first check is performed.")
  private Integer initialDelaySeconds;

  @ApiModelProperty("The number of seconds between checks.")
  private Integer periodSeconds;

  @ApiModelProperty("The number of seconds with no response that indicates a failure.")
  private Integer timeoutSeconds;

  @ApiModelProperty("Number of times the check is performed before giving up.")
  private Integer failureThreshold = 1;

  @ApiModelProperty("Minimum number of times the check needs to pass for the probe to be considered successful")
  private Integer successThreshold = 1;

  public ProbeTuning initialDelaySeconds(Integer initialDelaySeconds) {
    this.initialDelaySeconds = initialDelaySeconds;
    return this;
  }

  public Integer initialDelaySeconds() {
    return initialDelaySeconds;
  }

  public Integer getInitialDelaySeconds() {
    return initialDelaySeconds;
  }

  public void setInitialDelaySeconds(Integer initialDelaySeconds) {
    this.initialDelaySeconds = initialDelaySeconds;
  }

  public ProbeTuning periodSeconds(Integer periodSeconds) {
    this.periodSeconds = periodSeconds;
    return this;
  }

  public Integer periodSeconds() {
    return periodSeconds;
  }

  public Integer getPeriodSeconds() {
    return periodSeconds;
  }

  public void setPeriodSeconds(Integer periodSeconds) {
    this.periodSeconds = periodSeconds;
  }

  public ProbeTuning timeoutSeconds(Integer timeoutSeconds) {
    this.timeoutSeconds = timeoutSeconds;
    return this;
  }

  public Integer timeoutSeconds() {
    return timeoutSeconds;
  }

  public Integer getTimeoutSeconds() {
    return timeoutSeconds;
  }

  public void setTimeoutSeconds(Integer timeoutSeconds) {
    this.timeoutSeconds = timeoutSeconds;
  }

  public Integer getFailureThreshold() {
    return failureThreshold;
  }

  public ProbeTuning failureThreshold(Integer failureThreshold) {
    this.failureThreshold = failureThreshold;
    return this;
  }

  public Integer getSuccessThreshold() {
    return successThreshold;
  }

  public ProbeTuning successThreshold(Integer successThreshold) {
    this.successThreshold = successThreshold;
    return this;
  }

  @Override
  public String toString() {
    return new ToStringBuilder(this)
        .append("initialDelaySeconds", initialDelaySeconds)
        .append("periodSeconds", periodSeconds)
        .append("timeoutSeconds", timeoutSeconds)
        .append("failureThreshold", failureThreshold)
        .append("successThreshold", successThreshold)
        .toString();
  }

  @Override
  public boolean equals(Object other) {
    if (this == other) {
      return true;
    }

    if (other == null || getClass() != other.getClass()) {
      return false;
    }
    ProbeTuning rhs = (ProbeTuning) other;
    return new EqualsBuilder()
        .append(initialDelaySeconds, rhs.initialDelaySeconds)
        .append(periodSeconds, rhs.periodSeconds)
        .append(timeoutSeconds, rhs.timeoutSeconds)
        .append(failureThreshold, rhs.failureThreshold)
        .append(successThreshold, rhs.successThreshold)
        .isEquals();
  }

  @Override
  public int hashCode() {
    return new HashCodeBuilder(17, 37)
        .append(initialDelaySeconds)
        .append(periodSeconds)
        .append(timeoutSeconds)
        .append(failureThreshold)
        .append(successThreshold)
        .toHashCode();
  }
}
