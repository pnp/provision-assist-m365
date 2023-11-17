[CmdletBinding()]
Param
(
  [Parameter (Mandatory = $false)]
  [String] $siteURL
)

$tenantName = $siteUrl.Substring(0, $siteUrl.IndexOf(".")).Replace("https://", "")

try {
  #Connect to admin site
  Connect-PnPOnline -Url "https://$tenantName-admin.sharepoint.com" -ManagedIdentity

  #Get all site templates
  $siteTemplates = Get-PnPSiteDesign

  $siteTemplatesArr = New-Object System.Collections.Generic.List[System.Object]

  foreach ($siteTemplate in $siteTemplates) { 
    $siteTemplatesArr.Add(@{Title = $siteTemplate.Title; Description = $siteTemplate.Description; SiteTemplateId = $siteTemplate.Id; PreviewImage = $siteTemplate.PreviewImageUrl; WebTemplate = $siteTemplate.WebTemplate })
  }

  #Add ootb site templates to array - team sites
  $siteTemplatesArr.Add(@{Title = "Event planning"; Description = "Coordinate and plan event details with your team."; SiteTemplateId = "9522236e-6802-4972-a10d-e98dc74b3344"; PreviewImage = "https://modernb.akamai.odsp.cdn.office.net/files/odsp-web-prod_2021-07-02.006/odsp-media/images/webtemplatesgallery/previewimage/previewimageforeventplanning.jpg"; WebTemplate = "64"; Store = "1" })
  $siteTemplatesArr.Add(@{Title = "Project management"; Description = "Collaborate with your team to share project details and resources."; SiteTemplateId = "f0a3abf4-afe8-4409-b7f3-484113dee93e"; PreviewImage = "https://modernb.akamai.odsp.cdn.office.net/files/odsp-web-prod_2021-07-02.006/odsp-media/images/webtemplatesgallery/previewimage/previewimageforprojectmanagement.jpg"; WebTemplate = "64"; Store = "1" })
  $siteTemplatesArr.Add(@{Title = "Training and Courses"; Description = "Prepare training course participants for specific learning opportunities."; SiteTemplateId = "695e52c9-8af7-4bd3-b7a5-46aca95e1c7e"; PreviewImage = "https://modern.akamai.odsp.cdn.office.net/files/odsp-web-prod_2021-06-18.001/odsp-media/images/webtemplatesgallery/previewimage/previewimagefortraining.jpg"; WebTemplate = "64"; Store = "1" })
  $siteTemplatesArr.Add(@{Title = "Training and development team"; Description = "Brainstorm and plan opportunities to help others learn."; SiteTemplateId = "64aaa31e-7a1e-4337-b646-0b700aa9a52c"; PreviewImage = "https://modernb.akamai.odsp.cdn.office.net/files/odsp-web-prod_2021-06-18.001/odsp-media/images/webtemplatesgallery/previewimage/previewimagefordevelopment.jpg"; WebTemplate = "64"; Store = "1" })
  $siteTemplatesArr.Add(@{Title = "Crisis communication team"; Description = "Centralize crisis communication, resources, and best practices."; SiteTemplateId = "fb513aef-c06f-4dc3-b08c-963a2d2360c1"; PreviewImage = "https://res-1.cdn.office.net/files/sp-client/odsp-media-b77a4e00/images/webtemplatesgallery/previewimage/previewimageforcrisiscommunication.jpg"; WebTemplate = "64"; Store = "1" })
  $siteTemplatesArr.Add(@{Title = "Employee onboarding team"; Description = "Guide new employees through your team's onboarding process."; SiteTemplateId = "af9037eb-09ef-4217-80fe-465d37511b33"; PreviewImage = "https://res-1.cdn.office.net/files/sp-client/odsp-media-b77a4e00/images/webtemplatesgallery/previewimage/previewimageforonboardingteam.jpg"; WebTemplate = "64"; Store = "1" })
  $siteTemplatesArr.Add(@{Title = "IT Help desk"; Description = "Manage technical requests, track devices, and share training materials."; SiteTemplateId = "71308406-f31d-445f-85c7-b31942d1508c"; PreviewImage = "https://res-1.cdn.office.net/files/sp-client/odsp-media-b77a4e00/images/webtemplatesgallery/previewimage/preview-image-for-it-help-desk.jpg"; WebTemplate = "64"; Store = "1" })
  $siteTemplatesArr.Add(@{Title = "Retail management team"; Description = "Unite retail store managers, emphasize store news, and share management resources."; SiteTemplateId = "e4ec393e-da09-4816-b6b2-195393656edd"; PreviewImage = "https://res-1.cdn.office.net/files/sp-client/odsp-media-b77a4e00/images/webtemplatesgallery/previewimage/previewimageforretailmanagement.jpg"; WebTemplate = "64"; Store = "1" })
  $siteTemplatesArr.Add(@{Title = "Store collaboration"; Description = "Coordinate and prepare retail teams with current store news, resources, and training."; SiteTemplateId = "811ecf9a-b33f-44e6-81bd-da77729906dc"; PreviewImage = "https://res-1.cdn.office.net/files/sp-client/odsp-media-b77a4e00/images/webtemplatesgallery/previewimage/previewimageforstorecollaboration.jpg"; WebTemplate = "64"; Store = "1" })
  $siteTemplatesArr.Add(@{Title = "Team collaboration"; Description = "Manage projects, share content, and stay connected with your team."; SiteTemplateId = "6b96e7b1-035f-430b-92ca-31511c51ca72"; PreviewImage = "https://res-1.cdn.office.net/files/sp-client/odsp-media-b19ac753/images/webtemplatesgallery/previewimage/previewimageforbasicteam.jpg"; WebTemplate = "64"; Store = "1" })

  #Add ootb site templates to array - Communication sites
  $siteTemplatesArr.Add(@{Title = "Topic"; Description = "Use this design if you have a lot of information to share such as news, events, and other content."; SiteTemplateId = ""; PreviewImage = "https://spoprod-a.akamaihd.net/files/odsp-next-prod_2019-04-12-sts_20190422.002/odsp-media/images/designpackage/reportsite.png"; WebTemplate = "68" })
  $siteTemplatesArr.Add(@{Title = "Showcase"; Description = "Use this design to showcase a product, team, or event using photos or images."; SiteTemplateId = "6142d2a0-63a5-4ba0-aede-d9fefca2c767"; PreviewImage = "https://spoprod-a.akamaihd.net/files/odsp-next-prod_2019-04-12-sts_20190422.002/odsp-media/images/designpackage/portfoliosite.png"; WebTemplate = "68" })
  $siteTemplatesArr.Add(@{Title = "Blank"; Description = "Start with a blank site and make your design come to life quickly and easily."; SiteTemplateId = "f6cc5403-0d63-442e-96c0-285923709ffc"; PreviewImage = "https://spoprod-a.akamaihd.net/files/odsp-next-prod_2019-04-12-sts_20190422.002/odsp-media/images/designpackage/blanksite.png"; WebTemplate = "68" })
  $siteTemplatesArr.Add(@{Title = "Crisis management"; Description = "Share news, provide support, and connect people to resources in a crisis."; SiteTemplateId = "905bb0b4-01e8-4f55-b73c-f07f08aee3a4"; PreviewImage = "https://modern.akamai.odsp.cdn.office.net/files/odsp-web-prod_2021-06-11.003/odsp-media/images/webtemplatesgallery/previewimage/previewimageforcrisismanagement.jpg"; WebTemplate = "68"; Store = "1" })
  $siteTemplatesArr.Add(@{Title = "Department"; Description = "Engage viewers with department news, events, and resources."; SiteTemplateId = "73495f08-0140-499b-8927-dd26a546f26a"; PreviewImage = "https://modernb.akamai.odsp.cdn.office.net/files/odsp-web-prod_2021-07-02.006/odsp-media/images/webtemplatesgallery/previewimage/previewimagefordepartment.jpg"; WebTemplate = "68"; Store = "1" })
  $siteTemplatesArr.Add(@{Title = "Human resources"; Description = "Provide employees with compensation, benefits, and career resources."; SiteTemplateId = "73495f08-0140-499b-8927-dd26a546f26a"; PreviewImage = "https://modernb.akamai.odsp.cdn.office.net/files/odsp-web-prod_2021-07-02.006/odsp-media/images/webtemplatesgallery/previewimage/previewimagefordepartment.jpg"; WebTemplate = "68"; Store = "1" })
  $siteTemplatesArr.Add(@{Title = "Leadership connection"; Description = "Build organizational culture by connecting leadership and teams."; SiteTemplateId = "cd4c26b2-b231-419a-8bb4-9b1d9b83aef6"; PreviewImage = "https://modern.akamai.odsp.cdn.office.net/files/odsp-web-prod_2021-06-11.003/odsp-media/images/webtemplatesgallery/previewimage/previewimageforleadershipconnection.jpg"; WebTemplate = "68"; Store = "1" })
  $siteTemplatesArr.Add(@{Title = "Learning central"; Description = "Provide a landing experience for your organization's learning opportunities."; SiteTemplateId = "b8ef3134-92a2-4c9d-bca6-c2f14e79fe98"; PreviewImage = "https://modern.akamai.odsp.cdn.office.net/files/odsp-web-prod_2021-06-11.003/odsp-media/images/webtemplatesgallery/previewimage/previewimageforlearningcenter.jpg"; WebTemplate = "68"; Store = "1" })
  $siteTemplatesArr.Add(@{Title = "New employee onboarding"; Description = "Provide a landing experience for your organization's learning opportunities."; SiteTemplateId = "2a23fa44-52b0-4814-baba-06fef1ab931e"; PreviewImage = "https://modernb.akamai.odsp.cdn.office.net/files/odsp-web-prod_2021-07-02.006/odsp-media/images/webtemplatesgallery/previewimage/previewimagefordepartmentalonboarding.jpg"; WebTemplate = "68"; Store = "1" })
  $siteTemplatesArr.Add(@{Title = "Volunteer center"; Description = "Onboard, train, and prepare volunteers for campaigns and events."; SiteTemplateId = "b6e04a41-1535-4313-a856-6f3515d31999"; PreviewImage = "https://res-1.cdn.office.net/files/sp-client/odsp-media-b77a4e00/images/webtemplatesgallery/previewimage/previewimageforlearningcenter.jpg"; WebTemplate = "68"; Store = "1" })
  $siteTemplatesArr.Add(@{Title = "Event"; Description = "Share event information with attendees."; SiteTemplateId = "3e4352aa-0cff-44aa-87c9-fefba31f1434"; PreviewImage = "https://res-1.cdn.office.net/files/sp-client/odsp-media-b77a4e00/images/webtemplatesgallery/previewimage/previewimageforeventsite.jpg"; WebTemplate = "68"; Store = "1" })
  $siteTemplatesArr.Add(@{Title = "Human resources"; Description = "Provide employees with compensation, benefits, and career resources."; SiteTemplateId = "dbaeebd1-6b1e-49fc-b98e-f7c0eb954284"; PreviewImage = "https://res-1.cdn.office.net/files/sp-client/odsp-media-b77a4e00/images/webtemplatesgallery/previewimage/previewimageforhumanresource2.jpg"; WebTemplate = "68"; Store = "1" })


  $siteTemplatesJson = $siteTemplatesArr | ConvertTo-Json

  if ($siteTemplatesArr.Count -eq 1) {
    $siteTemplatesJson = "[$siteTemplatesJson]"
  }
  
  Write-Output $siteTemplatesJson
}

catch {
  Write-Output "Error occured: $PSItem"
}
finally {
  Disconnect-PnPOnline
}   