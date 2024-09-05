# 设置WinRAR下载页面的URL
$url = "https://www.win-rar.com/download.html"

# 尝试获取网页内容
try {
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing
} catch {
    Write-Host "无法访问WinRAR下载页面：$_"
    exit
}

# # 获取所有的超链接并输出
# $response.Links | ForEach-Object {
#     if ($_.href) {
#         # 输出超链接的href属性值
#         Write-Host $_.href
#     }
# }

# 提取页面中的所有超链接
$htmlLinks =$response.Links


# 筛选出包含特定路径和文件扩展名的链接
$selectedLink = $htmlLinks | Where-Object { $_.href -like "https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-[0-9]{3}.exe" }

# 输出筛选出的链接
if ($selectedLink) {
    Write-Host "yes:$($selectedLink.href)"
} else {
    Write-Host "no"
}

# 遍历筛选出的链接并输出
# foreach ($link in $selectedLinks) {
#     Write-Host $link.href
#     Write-Host $selectedLinks
# }