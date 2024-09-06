#每次点击后，下载WinRAR最新版
# 设置WinRAR下载页面的URL和下载的路径
$url = "https://www.win-rar.com/download.html"
$download_path = "C:\Users\11755\Documents"

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

#从网页中提取出所有符合特定模式的超链接
$selectedLink = $htmlLinks | Where-Object { $_.href -like "https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-***.exe" }

if ($selectedLink) {
    # 获取第一个链接
    $firstLink = $selectedLink | Select-Object -First 1

    # 使用 Format-Table 格式化输出
    $firstLink | Format-Table -Property href

    # 使用 Sort-Object 对链接进行排序
    $sortedLinks = $selectedLink | Sort-Object -Property href

    # 输出排序后的链接
    Write-Host "Sorted Links:"
    $sortedLinks | ForEach-Object { Write-Host $_.href }

    # 下载第一个链接
    Write-Host "downloading:" $firstLink
    Start-BitsTransfer -Source $firstLink.href -Destination $download_path
    Write-Host "End of download"

} else {
    Write-Host "fail to get"
}