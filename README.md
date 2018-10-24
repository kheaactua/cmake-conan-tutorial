# cmake-conan-tutorial

Small examples of how to use CMake with Conan to install dependencies.

# Requirements

- [Python](https://www.python.org/downloads/) (preferably >=3.6, but the scripts are backwards compatible)
- [Conan](https://conan.io/) (>1.0.2)

# Python Environment

While conan is compatible with Python 2.7 and Python 3, it is recommended to
use conan in a python virtual environment.  Moreover, the Conan package files
written at NTC are udo argeted at Python 3.6.

## Install Python
To set up this environment, first ensure you have Python installed.  The
preferred version is 3.6, see below for versions under 3.6.

Linux
```sh
sudo add-apt-repository ppa:jonathonf/python-3.6
sudo apt-get update
sudo apt-get install -y python3.6 python3-pip python3.6-dev
```

Windows: [Download Python](https://www.python.org/downloads/)

### Python <3.6

The conan packages used here have been made backwards compatible using
[future_fstrings](https://github.com/asottile/future-fstrings), to enable this,
run `pip install future-fstrings` on your system and/or in your virtual
environment (see the following section.)

## Install VirtualEnv

Install the python tool called
[virtualenv](https://virtualenv.pypa.io/en/stable/).  This tool allows you to
set up a local python environment, sort of like a Docker container.  Basically,
when you activate a specific python environment, all your python binaries
(*e.g.* `python`, `pip`, *etc.*) are set to use a specific version, and any python
package you install is installed into your local environment.

Linux
```sh
pip install virtualenv
```

Windows:
```
SET PYTHONPATH=%LOCALAPPDATA%\Programs\Python36
SET PATH=%PYTHONPATH%;%PYTHONPATH%\Scripts;%PATH%

pip install virutalenv
```

## Create your virtual environment

You can create a container (folder) for your virtual environment anywhere you
wish.  You may also name it anything you with.  For example, you can be very
generic and name it `python36` for example (though this somewhat defeats the
points of virtual environments), or you can make it almost application
specific, **i.e.** name it `conan`.  We'll do the latter.

Linux:
```sh
mkdir ${HOME}/python-envs
cd ${HOME}/python-envs

virutalenv -p python3.6 conan
```

Windows:
```
mkdir %USERPROFILE%\python-envs
cd %USERPROFILE%\python-envs

virutalenv -p python3.6 conan
```

## Activate the environment

Now that the environment is created, it's time to activate it.

Linux:
```sh
source ${HOME}/python-envs/conan/bin/activate
```

Windows:
```
%USERPROFILE%\python-envs\conan\Scripts\activate
```

## Install Conan to your local environment

```sh
pip install conan
```

# Setting up Conan

Conan is ready to use more-or-less out of the box.  However, at NTC, we will be
using the `jenkins` remote.  A conan remote is conceptually similar to a git
remote.  Essentially, it's a file repository that we can pull to and push from.

We'll set up this remote by syncronizing our config with the NTC conan config.
To set up this remote, type:

```sh
conan config install git@ntctrac.corp.neptec.com:nshiell/conan-config.git
```

This should also provide you with some default 3DRi profiles.  To view these, type:

```sh
conan profile list
```

Or to see a specific, such as the default profile, type:

```sh
conan profile show default
```

For the purposes of this tutorial, ensure your default is gcc, or you'll have
to specify the profile you wish to use with interacting with conan.

The profile used in this tutorial is:

```sh
[build_requires]
[settings]
os=Linux
os_build=Linux
arch=x86_64
arch_build=x86_64
compiler=gcc
compiler.version=4.8
compiler.libcxx=libstdc++
build_type=Release

[options]
pcl:shared=True

[env]
&:ninja_installer/[>=1.8.2]@ntc/stable
cmake_installer/[>=3.6.3]@conan/stable
```

If your profile differs, you can write this into `${HOME}/.conan/profiles/default`.

Note, this example is tailored towards 14.04.  If you are using 16.04, you may
be using `libstdc++11`.  This can result in issues if you are also attempting
to include Qt.

## Notes

- This will add the remote to the end of your remote list, meaning it gets searched last.  If this proves annoying, you can re-order the remote manually in `${HOME}/.conan/registry.txt`
- This will likely soon change.  Also, it seems that the server has DNS issues.  Specifically, it's hostname is not a registered DNS alias, and this causes some issues.  For now, I've been getting around this issue by adding the host `NTCBuild64_2` to `10.10.0.78` in my local host file.  On Linux this is `/etc/hosts`, on Windows this is `C:\Windows\System32\Drivers\etc\hosts`.  This hack is temporary.)

# Build Example Project

For this step, we're going to assume that a Conan PCL package already exists
(we'll visit creating that package after.)  Enter the `example-project`
directory.  You'll see a `conanfile.py` file here.  This file specifies all the
packages we'll use in our project.  You'll also see a `CMakeFile.txt` file,
this is the CMake file for a typical project with some Conan directives added
in.

*Recall*, everything in this tutorial is tailored towards integration with
current Neptec source code.  This effectively means that while many solutions
exist to solve any one problem, this tutorial chooses the solutions will
integrate the best - or rather - use the more similar patterns, as Neptec
source code does.

Create an *in-source* build directory named `bld` and run `conan install`, *e.g.*:
```sh
mkdir bld
cd bld

conan install ..
```

You'll see that PCL, along will all of it's dependencies (boost, eigen, flann,
*etc*) are installed.  You'll also see a `conanbuildinfo.cmake` file (and a
`.txt` file, but we'll ignore that one.)

The CMake file attempts to build a simple PCL app (`main.cpp`) that depends on
`OPAL_PCL` - our wrapper for `PCL`.  **Note** Conan does define actual targets
for PCL, so ordinarily there is no need to wrap it in a custom target.  We wrap
it here for so that it'll integrate better with Neptec code

You'll also see that the `CMakeLists.txt` file has two Conan related
directives, namely `include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)` and
`conan_basic_setup()`.  The former loads the generate CMake file, and the
latter sets up the variables, generators, and targets (that we can't use with
this version of CMake)

Now, use the `cmake build` command to build the project:
```sh
conan build -sf .. -bf . ..
```

where `-sf` points at the **source** folder, `-bf` points at the
**build**-folder, and we point to the directory containing our recipe.

Note:  Once the `conan build` command has been issued once, we could also call
CMake explicitly like any other, but to do this it is important that we load
the conan virtual environment:

```sh
# Load CMake and other build requirements using the Conan Virtual Environment
source activate.sh

cmake .
ninja
```

# Discussion Notes on PCL Package File

This section contains rough points to discuss during the tutorial

- The package is technically "**version agnostic**".  This is done by only specifying the version when creating the package.  Typically each package file is in its own git repository and each version is stored as a branch.  This package was done like this however because it was created along with a multitude of conan packages that all have to work together.
- Notice that while most dependencies are `@ntc`, `gtest` is from `lasote`.  This is a huge advantage unique to a package manager, where if it already exists, then we can just use it with almost no effort.
- The versions of the dependents is quite loose, *e.g.* `boost/[>1.46]`.  This is because as far as I'm aware, PCL is fine with any version of boost greater than 1.46.  This allows the packages to more easily intermix.
- `options` is a tuple of options that allow us to inject variation into the package, which will generate a package with a unique ID.  Thus, PCL 1.7.2 static has a different ID than PCL 1.7.2 shared.
- Discussion of what libs in `package_info` to place in `libs`.  I've converged to thinking that simply the library name (without prefix or suffix) is best.  This is optimal because they can then be searched for with CMake's `find_library`.  This fails however in instances where CMake wants a full path to a specific library, suffix and all (*i.e.* `zlib`.)  Also, it's probably best only to pack the immediate libraries, rather than the dependencies as well, the OpenCV package currently does this, and that renders this property more or less unusable.  All said though, this only works in simple cases, larger vendors that build different libraries depending on the options, and only load some at any given time, require unique considerations.

# Resources

- [Documentation](http://docs.conan.io/en/latest/index.html)
- [CppCon 2016: Diego Rodriguez-Losada “Conan, a C and C++ package manager for developers"](https://www.youtube.com/watch?v=xvqH_ck-5Q8)
- [CppCon 2017: D. Rodriguez-Losada Gonzalez “Faster Delivery of Large C/C++ Projects with Conan](https://www.youtube.com/watch?v=xA9yRX4Mdz0)
