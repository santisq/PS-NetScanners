﻿using namespace System.IO

$moduleName = (Get-Item ([Path]::Combine($PSScriptRoot, '..', 'module', '*.psd1'))).BaseName
$manifestPath = [Path]::Combine($PSScriptRoot, '..', 'output', $moduleName)

Import-Module $manifestPath
Import-Module ([Path]::Combine($PSScriptRoot, 'common.psm1'))

Describe TestPingAsyncCommand {
    Context 'Output Streams' {
        It 'Success' {
            Test-PingAsync -Target github.com |
                Should -BeOfType ([PSNetScanners.PingResult])
        }

        It 'Error' {
            { Test-PingAsync -Target doesNotExist.com -ErrorAction Stop } |
                Should -Throw

            { Test-PingAsync -Target noSuchAddress -ErrorAction Stop } |
                Should -Throw
        }
    }

    Context 'DnsResult Type' {
        It 'DnsSuccess' {
            $result = Test-PingAsync google.com -ResolveDns
            $result.DnsResult | Should -BeOfType ([PSNetScanners.DnsSuccess])
            $result.DnsResult.Status | Should -Be ([PSNetScanners.DnsStatus]::Success)
        }

        It 'DnsFailure' {
            $result = Test-PingAsync 127.0.0.2 -ResolveDns
            $result.DnsResult | Should -BeOfType ([PSNetScanners.DnsFailure])
            $result.DnsResult.Status | Should -Be ([PSNetScanners.DnsStatus]::Error)
        }
    }

    Context 'Test-PingAsync' {
        BeforeAll {
            $range = makeiprange 127.0.0 1 255
            $range | Out-Null
        }

        It 'Parallel Pings' {
            Measure-Command { $range | Test-PingAsync } |
                ForEach-Object TotalMinutes |
                Should -BeLessThan 2
        }

        It 'Stops processing early' {
            Measure-Command { $range | Test-PingAsync | Select-Object -First 10 } |
                ForEach-Object TotalSeconds |
                Should -BeLessThan 10
        }
    }

    Context 'Parameters' {
        BeforeAll {
            $range = makeiprange 127.0.0 1 20
            $range | Out-Null
        }

        It 'ConnectionTimeout' {
            { $range | Test-PingAsync -ConnectionTimeout 200 -ErrorAction Stop } |
                Should -Not -Throw
        }

        It 'ThrottleLimit' {
            { $range | Test-PingAsync -ThrottleLimit 300 -ErrorAction Stop } |
                Should -Not -Throw
        }

        It 'BufferSize' {
            { $range | Test-PingAsync -BufferSize 1 -ErrorAction Stop } |
                Should -Not -Throw
        }

        It 'Ttl' {
            { $range | Test-PingAsync -Ttl 1 -ErrorAction Stop } |
                Should -Not -Throw
        }

        It 'DontFragment' {
            { $range | Test-PingAsync -DontFragment -ErrorAction Stop } |
                Should -Not -Throw
        }
    }
}
