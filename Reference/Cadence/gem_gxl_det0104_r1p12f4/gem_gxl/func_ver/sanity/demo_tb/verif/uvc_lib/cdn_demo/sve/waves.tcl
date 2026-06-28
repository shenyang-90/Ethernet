database -open waves -into waves.shm -default
probe -create cdn_demo_tb -depth all -all

catch {
if { [file exists [glob $::env(CDN_DEMO_PATH)/verif/uvc_lib/*/*/*.svcf]] == 1} {
   set waves [glob $::env(CDN_DEMO_PATH)/verif/uvc_lib/*/*/*.svcf]
   if {${waves} != ""} {
      simvision -input ${waves}
   }
} 
}
