extern crate rustc_serialize;
use hyper;
//use hyper::header;
//use rustc_serialize::json::{self, Json};
//use rustc_serialize::Decodable;
//use hyper::mime;

pub struct Client {
  http: hyper::Client,
  user_agent: String,
}

pub struct ListRepositoriesRequest;

impl Client {
  pub fn new() -> Client {
    Client {
      http: hyper::Client::new(),
      user_agent: "test 1".to_string(),
    }
  }

  //let rb = client.get("https://api.github.com/orgs/logstash-plugins/repos")
           //.header(header::Accept(vec![header::qitem(github_json_mime)]))
           //.header(header::UserAgent("learning-is-fun 0.1".to_owned()));
}

#[cfg(test)]
mod test {
  use github;
  use hyper::client;

  #[test]
  fn test_new_client() {
    let gh = github::client::Client::new();
    assert_eq!(gh.user_agent, "test 1".to_string());
    let _ = gh.http.get("http://localhost:1234");
  }
}
