#include <iostream>

#include <pcl/point_cloud.h>
#include <pcl/point_types.h>

auto main(int argc, char* argv[]) -> int {
    pcl::PointCloud<pcl::PointXYZ> cloud;
    std::cout << "Created a PCL cloud of size " << cloud.size() << std::endl;
}

/* vim: set ts=4 sw=4 sts=4 expandtab ffs=unix,dos : */
