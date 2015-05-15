#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

cd "$scriptPath"/bin/classes
zip -r ../classes.jar *
