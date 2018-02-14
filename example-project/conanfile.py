#!/usr/bin/env python
# -*- coding: utf-8 -*-

from conans import ConanFile, CMake, tools, RunEnvironment
import os


class PclExampleConan(ConanFile):
    settings = 'os', 'compiler', 'build_type', 'arch'
    generators = 'cmake'

    requires = (
        'pcl/1.7.2@ntc/stable',
    )

    def configuration(self):
        self.options['pcl'].shared = True

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

# vim: ts=4 sw=4 expandtab ffs=unix ft=python foldmethod=marker :
