extern crate futures;
extern crate tokio_core;
extern crate tokio_process;

use futures::Future;
use std::fmt;

enum MyError {
  StartSubprocess(std::io::Error),
  WaitSubprocess(std::io::Error),
  SubprocessExit(std::process::Output),
  HostDown,
}

impl fmt::Display for MyError {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    match self {
      MyError::StartSubprocess(e) => write!(f, "failed to start subprocess: {}", e),
      MyError::WaitSubprocess(e) => write!(f, "failed to wait for subprocess to exit: {}", e),
      MyError::SubprocessExit(output) => {
        let stderr = String::from_utf8_lossy(&output.stderr);
        let stderr = stderr.trim();
        match output.status.code() {
          Some(code) => write!(f, "subprocess failed with exit code {}: {}", code, stderr),
          None => write!(f, "subprocess failed with unknown exit code: {}", stderr),
        }
      },
      MyError::HostDown => write!(f, "host is down"),
    }
  }
}

trait Test {
  fn run(&self) -> Box<Future<Item=(), Error=MyError>>;
}

struct Ping(String);

impl Ping {
  fn make_command(&self) -> std::process::Command {
    use std::process::{Command, Stdio};
    let mut cmd = Command::new("ping");
    cmd.args(&["-c1", "-w1", &self.0])
      .stdin(Stdio::null())
      .stdout(Stdio::null())
      .stderr(Stdio::piped());
    cmd
  }
  fn start_process(&self) -> impl Future<Item=tokio_process::Child, Error=MyError> {
    use tokio_process::CommandExt;
    futures::future::result(self.make_command().spawn_async().map_err(MyError::StartSubprocess))
  }
  fn get_output(&self) -> impl Future<Item=std::process::Output, Error=MyError> {
    self.start_process().and_then(move |process| process.wait_with_output().map_err(MyError::WaitSubprocess))
  }
}

impl Test for Ping {
  fn run(&self) -> Box<Future<Item=(), Error=MyError>> {
    Box::new(self.get_output().and_then(move |output| {
      if output.status.success() {
        futures::future::ok(())
      } else if output.status.code() == Some(1) {
        futures::future::err(MyError::HostDown)
      } else {
        futures::future::err(MyError::SubprocessExit(output))
      }
    }))
  }
}

impl fmt::Display for Ping {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    write!(f, "ping {}", &self.0)
  }
}

fn run_test<T: fmt::Display + Test>(test: T) -> impl Future<Item=String, Error=()> {
  test.run().then(move |result| futures::future::ok(
    match result {
      Ok(()) => format!("{}: ok", test),
      Err(e) => format!("{}: fail: {}", test, e),
    }
  ))
}

fn main() {
  use futures::future::join_all;
  use tokio_core::reactor::Core;

  let ping_hosts = &[
    "1.1.1.1",
    "1.0.0.1",
    "2606:4700:4700::1111",
    "2606:4700:4700::1001",
    "80.85.84.13", "campanella2.pub4.s.cascade",
    "176.9.121.81", "beagle2.pub4.s.cascade",
    "192.168.1.1", "gateway.w4.s.cascade",
    "192.168.1.20", "coloris.w4.s.cascade",
    "192.168.1.30", "altusanima.w4.s.cascade",
    "fca5:cade:1::1:1", "campanella2.cv.s.cascade",
    "fca5:cade:1::1:2", "altusanima.cv.s.cascade",
    "fca5:cade:1::2:1", "altusanima.cl.s.cascade",
    "fca5:cade:1::2:3", "shadowshow.cl.s.cascade",
    "fca5:cade:1::2:5", "bonito.cl.s.cascade",
    "fca5:cade:1::2:6", "cherry.cl.s.cascade",
    "fca5:cade:1::3:1", "altusanima.cvl.s.cascade",
    "fca5:cade:1::3:2", "coloris.cvl.s.cascade",
    "192.168.2.1", "altusanima.cl4.s.cascade",
    "192.168.2.3", "shadowshow.cl4.s.cascade",
    "192.168.2.5", "bonito.cl4.s.cascade",
    "192.168.2.6", "cherry.cl4.s.cascade",
  ];

  let execute_tests = ping_hosts.iter().map(|host| run_test(Ping(String::from(*host))));
  let execute_everything = join_all(execute_tests).map(|lines| {
    for line in lines {
      println!("{}", line);
    }
  });

  let mut core = Core::new().unwrap();
  match core.run(execute_everything) {
    Ok(()) => (),
    Err(()) => unreachable!(),
  }
}
