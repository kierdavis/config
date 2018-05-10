{
  ### BANDWIDTH ###
  alt-speed-enabled = false;
  #alt-speed-up  # in kB/s, default = 50
  #alt-speed-down  # in kB/s, default = 50
  speed-limit-down = 2000;  # in kB/s, default = 100
  speed-limit-down-enabled = true;
  speed-limit-up = 2000;  # in kB/s, default = 100
  speed-limit-up-enabled = true;
  #upload-slots-per-torrent  # default = 14

  ### BLOCKLISTS ###
  #blocklist-url
  blocklist-enabled = false;

  ### FILES AND LOCATIONS ###
  #download-dir = "/net/gyroscope/torrents";
  #incomplete-dir
  incomplete-dir-enabled = false;
  preallocation = 1;  # 0 = Off, 1 = Fast, 2 = Full
  rename-partial-files = true;
  start-added-torrents = true;
  trash-original-torrent-files = false;
  #umask
  #watch-dir = "/var/lib/transmission/torrents";
  watch-dir-enabled = false;

  ### MISC ###
  #cache-size-mb  # MB, default = 4
  dht-enabled = true;  # Distributed Hash Table
  encryption = 2;  # 0 = allow, 1 = prefer, 2 = require
  #lazy-bitfield-enabled
  lpd-enabled = true;
  message-level = 2;  # 0 = none, 1 = error, 2 = info, 3 = debug
  pex-enabled = true;  # Peer Exchange
  prefetch-enabled = true;
  #scrape-paused-torrents-enabled
  script-torrent-done-enabled = false;
  #script-torrent-done-filename
  utp-enabled = true;

  ### PEERS ###
  #bind-address-ipv4
  #bind-address-ipv6
  #peer-congestion-algorithm
  #peer-id-ttl-hours
  peer-limit-global = 300;
  peer-limit-per-torrent = 50;
  #peer-socket-tos  # default, lowcost, throughput, lowdelay, reliability

  ### PEER PORT ###
  peer-port = 51413;
  #peer-port-random-high
  #peer-port-random-low
  peer-port-random-on-start = false;
  port-forwarding-enabled = true;

  ### QUEUEING ###
  download-queue-enabled = false;
  download-queue-size = 5;
  queue-stalled-enabled = true;
  queue-stalled-minutes = 30;
  seed-queue-enabled = false;
  seed-queue-size = 10;

  ### RPC ###
  rpc-authentication-required = true;
  rpc-bind-address = "0.0.0.0";
  rpc-enabled = true;
  rpc-password = (import ../secret/passwords.nix).transmissionWeb;
  rpc-port = 9091;
  #rpc-url
  rpc-username = "kier";
  rpc-whitelist = "127.0.0.1,10.99.*.*";  # comma separated
  rpc-whitelist-enabled = false;

  ### SCHEDULING ###
  alt-speed-time-enabled = false;
  #alt-speed-time-begin
  #alt-speed-time-end
  #alt-speed-time-day
  #idle-seeding-limit
  idle-seeding-limit = false;
  #ratio-limit
  ratio-limit-enabled = false;
}
