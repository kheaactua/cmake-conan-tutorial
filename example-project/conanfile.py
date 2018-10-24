#!/usr/bin/env python
# -*- coding: future_fstrings -*-
# -*- coding: utf-8 -*-

from conans import ConanFile, CMake, tools
import os


class PclExampleConan(ConanFile):
    settings = 'os', 'compiler', 'build_type', 'arch'
    generators = 'cmake', 'virtualenv'

    requires = (
        'pcl/[>=1.7.2]@ntc/stable',
    )

    def requirements(self):
        if tools.os_info.is_linux and '14.04' == tools.os_info.os_version and 'x86_64' == self.settings.arch:
            self.requires('qt/5.3.2@ntc/manual', override=True)
        else:
            self.requires('qt/5.3.2@ntc/stable', override=True)

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

# vim: ts=4 sw=4 expandtab ffs=unix ft=python foldmethod=marker :
