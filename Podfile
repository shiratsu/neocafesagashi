platform :ios, '7.0'

#pod 'KINWebBrowser'
pod 'SMCalloutView'
pod 'PonyDebugger' 
pod 'FMDB'

 
post_install do | installer |
 
  # HEADER_SEARCH_PATHS に $(inherited) を追加する
  workDir = Dir.pwd
  xcconfigFilename = "#{workDir}/Pods/Pods.xcconfig"
  xcconfig = File.read(xcconfigFilename)
  newXcconfig = xcconfig.gsub(/HEADER_SEARCH_PATHS = "/, "HEADER_SEARCH_PATHS = $(inherited) \"")
  File.open(xcconfigFilename, "w") { |file| file << newXcconfig }
   
end

