﻿using System.Net;
using System.Net.NetworkInformation;
using System.Threading.Tasks;

namespace PSNetScanners;

public sealed class PingResult
{
    private string? _displayAddress;

    private IPAddress? _address;

    public string Source { get; }

    public string Destination { get; }

    public IPAddress? Address
    {
        get => _address ??= Status is IPStatus.Success ? Reply?.Address : null;
    }

    public string DisplayAddress
    {
        get => _displayAddress ??= Address?.ToString() ?? "*";
    }

    public long? Latency { get => Reply?.RoundtripTime; }

    public IPStatus Status { get => Reply?.Status ?? IPStatus.TimedOut; }

    public DnsResult? DnsResult { get; private set; }

    public PingReply? Reply { get; private set; }

    private PingResult(string source, string target)
    {
        Source = source;
        Destination = target;
    }

    public static async Task<PingResult> CreateAsync(
        string source,
        string target,
        Cancellation cancellation)
    {
        return new PingResult(source, target)
        {
            Reply = await PingAsync(target, cancellation),
            DnsResult = await DnsAsync.GetHostEntryAsync(target, cancellation)
        };
    }

    private static async Task<PingReply?> PingAsync(
        string target,
        Cancellation cancellation)
    {
        if (cancellation.IsCancellationRequested)
        {
            return null;
        }

        using Ping ping = new();
        Task<PingReply> pingTask = ping.SendPingAsync(target);
        Task task = await Task.WhenAny(pingTask, cancellation.Task);

        if (task == cancellation.Task)
        {
            return null;
        }

        PingReply reply = await pingTask;
        return reply;
    }
}
