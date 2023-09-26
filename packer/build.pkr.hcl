build {
  sources = [
    "source.amazon-ebs.windows-2019"
  ]

  provisioner "shell" {
    only   = ["amazon-ebs.windows-2019"]
    inline = [
      "C:/ProgramData/Amazon/EC2-Windows/Launch/Scripts/InitializeDisks.ps1",
      "C:/ProgramData/Amazon/EC2-Windows/Launch/Scripts/InitializeInstance.ps1 -SchedulePerBoot"      
    ]
  } 

  provisioner "file" {
    source      = "./scripts/ResizePartition.ps1"
    destination = "D:/OutSystems/packer/ResizePartition.ps1"
  }
  
  provisioner "shell" {
    inline = [
      "id"
    ]
  }

  post-processor "manifest" {
  }

}