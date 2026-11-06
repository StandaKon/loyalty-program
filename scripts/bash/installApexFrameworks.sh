#!/bin/bash

# Install apex-mockery
sf package install --skip-handlers FeatureEnforcement --package apex-mockery --publish-wait 8 --wait 30

# Install Apex Trigger Actions Framework
sf package install --skip-handlers FeatureEnforcement --package trigger-actions-framework --publish-wait 8 --wait 30

# Install Enehano logger
sf package install --skip-handlers FeatureEnforcement --package enehano-logger --publish-wait 8 --wait 30 -k Enehano.7