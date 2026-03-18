
# Use Swift Vapor to host a localhost pip simple index server

make vapor generate html for simple index, shouldnt require that much 
else look in PipRepo.swift
* .build/index-build/checkouts/WheelBuilder/Sources/PipRepo/PipRepo.swift

generate package in 
./VaporSimpleServer 
and setup for vapor and the simple html server..

i guess later we can make more advanced stuff where server can download pip src, patch them and build them and then return simple with the version build included.. 



it should work as a executable, but seperate Vapor logic as Core library and executable uses the Core Library.

use Foundation.URL/FileManager if PathKit is a Swift 6.0 issue..
else there is always 
@preconcurrency import PathKit