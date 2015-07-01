extern crate hyper;
extern crate rustc_serialize;
use hyper::Client;
use std::io::Read;
use hyper::header;
use rustc_serialize::json::{self, Json};
use rustc_serialize::Decodable;
use hyper::mime;

/// This example was written against Rust 1.1
/// It will fetch a list of repositories from the 'logstash-plugins' org on GitHub
/// and print the names of each repository
///
/// This doesn't yet query each page of results, though, and only shows the first page.

fn main() {
  let github_json_mime: mime::Mime = "application/vnd.github.v4+json".parse().unwrap();

  let client = Client::new();
  let rb = client.get("https://api.github.com/orgs/logstash-plugins/repos")
           .header(header::Accept(vec![header::qitem(github_json_mime)]))
           .header(header::UserAgent("learning-is-fun 0.1".to_owned()));
  let result = rb.send();
  match result {
    Ok(response) => { 
      println!("{:?}", response.headers);
      //response.x();
      parse(response);
    },
    Err(err) => {
      println!("http errror: {}", err);
    },
  }
}

#[derive(RustcDecodable, Debug)]
pub struct Repository {
  id: u64,
  name: String,
  full_name: String,
  description: Option<String>,
  fork: bool,

  // There are other fields, I just haven't included them.
}

fn parse<T: Read>(mut r: T) {
  let x = Json::from_reader(&mut r);
  let j = match x {
    Ok(j) => { j },
    Err(err) => { panic!("Err: {}", err); },
  };

  let j = match j {
    Json::Array(j) => { j },
    _ => { panic!("Expected Array, got something else"); }
  };

  for item in j {
    let mut decoder = json::Decoder::new(item);
    match Decodable::decode(&mut decoder) {
      Ok(decoded) => {
        let repo: Repository = decoded;
        println!("{}", repo.full_name);
      },
      Err(err) => { panic!("Err: {}", err); }
    }
  }
}
