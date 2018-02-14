# cmake-conan-tutorial

Small examples of how to use CMake with Conan to install dependencies.

# Requirements

- [CMake](https://cmake.org/) (>=3.0.2)
- [Python](https://www.python.org/downloads/) (>=3.6)
- [Conan](https://conan.io/) (>1.0.2)

# Python Environment

While conan is compatible with Python 2.7 and Python 3, it is recommended to
use conan in a python virutal envionment.  Moreover, the Conan package files
written at NTC are targetted at Python 3.6.

## Install Python
To set up this environment, first ensure you have Python3.6 installed.

Linux
```sh
sudo add-apt-repository ppa:jonathonf/python-3.6
sudo apt-get update
sudo apt-get install python3.6
```

Windows: [Download Python](https://www.python.org/downloads/)

## Install VirtualEnv

Install the python tool called
[virtualenv](https://virtualenv.pypa.io/en/stable/).  This tool allows you to
set up a local python environment, sort of like a Docker container.  Basically,
when you activate a specific python environment, all your ``python binaries
(*e.g.* `python`, `pip`, etc) are set to use a specific version, and any python
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
generic and name it `python36` for example (though this someone defeats the
points of virutal environments), or you can make it almost application
speicifc, *i.e.* name it `conan`.  We'll do the latter.

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
To set up this remote, type:

```
conan remote add jenkins http://10.10.0.78:9300
```

You also want to ensure your profile is set up.  Typically the default profile
is sufficient, but it's worth checking in case you've injected clang or some
other compiler into your environment.  This can be seen by typing

```
conan profile list
````

and

```
conan profile show default
```

For the puporses of this tutorial, ensure your default is gcc, or you'll have
to specify the profile you wish to use with interacting with conan.

The profile used in this tutorial is:

```
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
[env]
```

If your profile differs, you can write this into `${HOME}/.conan/profiles/default`


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

*Recall*, everything in this tutorial is taylored towards integration with
current Neptec source code.  This effectively means that while many solutions
exist to solve any one problem, this tutorial chooses the solutions will
integrate the best - or rather - use the more similar patterns, as Neptec
source code does.

Create an *in-source* bld directory named `bld` and run `conan install`, e.g.:
```sh
mkdir bld
cd bld

conan install ..
```

You'll see that PCL, along will all of it's dependencies (boost, eigen, flann,
etc) are installed.  You'll also see a `conanbuildinfo.cmake` file (and a
`.txt` file, but we'll ignore that one.)

The CMake file attempts to build a simple PCL app (`main.cpp`) that depends on
`OPAL_PCL` - our wrapper for `PCL`.  **Note** Conan does define actual targets
for PCL, so ordinarily there is no need to wrap it in a custom target.  We wrap
it here for two reasons:

1. It'll integrate better with Neptec code
1. We currently only require `CMake` v3.0.2, whereas Conan requires v3.1.0 to
   create targets.  Therefore, even our custom find script has a lot of
   additional code to compensate for the lack of targets.

You'll also see that the `CMakeLists.txt` file has two Conan related
directives, namely `include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)` and
`conan_basic_setup()`.  The former loads the generate CMake file, and the
latter sets up the variables, generators, and targets (that we can't use with
this version of CMake)

Now, build the project like any other:
```sh
cmake -GNinja -DCMAKE_BUILD_TYPE=Release ..
ninja
```

# Resources

- [Documentation](http://docs.conan.io/en/latest/index.html)
- [CppCon 2016: Diego Rodriguez-Losada “Conan, a C and C++ package manager for developers"](https://www.youtube.com/watch?v=xvqH_ck-5Q8)
- [CppCon 2017: D. Rodriguez-Losada Gonzalez “Faster Delivery of Large C/C++ Projects with Conan](https://www.youtube.com/watch?v=xA9yRX4Mdz0)