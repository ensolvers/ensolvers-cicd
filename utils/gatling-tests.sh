#!/bin/bash

TEST_DIR="$1"
SIMULATION_CLASS="$2"
GATLING_ARGS="$3"

cd $TEST_DIR

mvn gatling:test -Dgatling.simulationClass=$SIMULATION_CLASS  "$GATLING_ARGS"