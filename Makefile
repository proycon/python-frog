PY_VERSIONS=cp36-cp36m cp37-cp37m cp38-cp38 cp39-cp39 cp310-cp310 cp311-cp311
BUILD_REQUIREMENTS=cython
#system packages (yum, manylinux_2_28 uses AlmaLinux)
SYSTEM_PACKAGES_RHEL=libicu-devel libxml2-devel libxslt-devel libexttextcat zlib-devel bzip2-devel libtool autoconf-archive autoconf automake m4 wget
#musllinux_1_1_x86_64 builds on Alpine v3.12
SYSTEM_PACKAGES_ALPINE=icu-dev libxml2-dev libxslt-dev libexttextcat-dev zlib-dev bzip2-dev libtool autoconf-archive autoconf automake m4 wget
PRE_BUILD_COMMAND=/io/build-deps.sh
PACKAGE_PATH=
PIP_WHEEL_ARGS=-w ./dist --no-deps
TAG=latest

.PHONY: wheels
wheels: manywheels muslwheels

.PHONY: manywheels
manywheels:
	docker pull quay.io/pypa/manylinux_2_28_x86_64:${TAG}
	docker run --rm -e PLAT=manylinux_2_28_x86_64 -v `pwd`:/io quay.io/pypa/manylinux_2_28_x86_64:${TAG} /io/build-wheels.sh "${PY_VERSIONS}" "${BUILD_REQUIREMENTS}" "${SYSTEM_PACKAGES_RHEL}" "${PRE_BUILD_COMMAND}" "${PACKAGE_PATH}" "${PIP_WHEEL_ARGS}"

.PHONY: muslwheels
muslwheels:
	docker pull quay.io/pypa/musllinux_1_1_x86_64:${TAG}
	docker run --rm -e PLAT=musllinux_1_1_x86_64 -v `pwd`:/io quay.io/pypa/musllinux_1_1_x86_64:${TAG} /io/build-wheels.sh "${PY_VERSIONS}" "${BUILD_REQUIREMENTS}" "${SYSTEM_PACKAGES_ALPINE}" "${PRE_BUILD_COMMAND}" "${PACKAGE_PATH}" "${PIP_WHEEL_ARGS}"

.PHONY: devwheels
devwheels:
	#builds against latest development versions of everything, these wheels should NOT be published!
	docker pull quay.io/pypa/manylinux_2_28_x86_64:${TAG}
	docker run --rm -e PLAT=manylinux_2_28_x86_64 -v `pwd`:/io quay.io/pypa/manylinux_2_28_x86_64:${TAG} /io/build-wheels.sh "${PY_VERSIONS}" "${BUILD_REQUIREMENTS}" "${SYSTEM_PACKAGES_RHEL}" "${PRE_BUILD_COMMAND} --devel" "${PACKAGE_PATH}" "${PIP_WHEEL_ARGS}"
	echo "Built against development versions, DO NOT PUBLISH these wheels!"

.PHONY: install
install:
	pip install .

.PHONY: deps
deps:
	./build-deps.sh
