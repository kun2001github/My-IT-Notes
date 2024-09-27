[System.Console]::OutputEncoding = [System.Console]::InputEncoding = [System.Text.Encoding]::UTF8


if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Insufficient permissions!"
    Break
}
# # 检查所需的命令是否存在
# $commands = @('Get-NetAdapter', 'Disable-NetAdapter', 'Enable-NetAdapter')
# foreach ($command in $commands) {
#     if (-not (Get-Command -Name $command)) {
#         Write-Error "命令 '$command' 不可用。请确保你使用的是支持该命令的Windows版本。"
#         exit
#     }
# }

# 获取所有网络适配器
$netAdapters = Get-NetAdapter

# 遍历所有网络适配器
foreach ($adapter in $netAdapters) {
    # 检查网络适配器的状态是否为“已连接”
    if ($adapter.Status -eq "Up") {
        try {
            # 关闭网络适配器
            Disable-NetAdapter -Name $adapter.Name -Confirm:$false
            Write-Host "已关闭网络适配器: $($adapter.Name)"

            # 等待1秒，确保网络适配器完全关闭
            Start-Sleep -Seconds 1

            # 重新启动网络适配器
            Enable-NetAdapter -Name $adapter.Name -Confirm:$false
            Write-Host "已重新启动网络适配器: $($adapter.Name)"
        } catch {
            Write-Error "操作失败：$_"
        }
    }
}