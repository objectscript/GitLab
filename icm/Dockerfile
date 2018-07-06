FROM intersystems/iris:2018.1.1-released

ENV SRC_DIR=/tmp/src
ENV CI_DIR=$SRC_DIR/ci
ENV CI_PROJECT_DIR=$SRC_DIR

COPY ./ $SRC_DIR

RUN cp $CI_DIR/iris.key $ISC_PACKAGE_INSTALLDIR/mgr/ \
 && cp $CI_DIR/GitLab.xml $ISC_PACKAGE_INSTALLDIR/mgr/ \
 && $ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/changePassword.sh $CI_DIR/pwd.txt \
 && iris start $ISC_PACKAGE_INSTANCENAME \
 && irissession $ISC_PACKAGE_INSTANCENAME -U USER < $CI_DIR/load_ci.script \
 && iris stop $ISC_PACKAGE_INSTANCENAME quietly