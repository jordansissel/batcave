use hyper;
use github;
use hyper::mime;

pub struct Client {
  http: hyper::Client,
  pub user_agent: String,
}

fn github_accept_mime() -> mime::Mime {
  // I couldn't figure out how to load the `mime!` macro, and
  // further, I couldn't figure out how to set this as a const. Oh well.
  let m: mime::Mime = "application/vnd.github.v4+json".parse().unwrap();
  m
}

impl Client {
  pub fn new() -> Client {
    Client {
      http: hyper::Client::new(),
      user_agent: "test 1".to_string(),
    }
  }

  pub fn get(&self, path: String) -> hyper::error::Result<hyper::client::response::Response> {
    let url = format!("https://api.github.com:443/{}", path);
    println!("GET {}", url);

    let request = self.http.get(&url)
      .header(hyper::header::Accept(vec![hyper::header::qitem(github_accept_mime())]))
      .header(hyper::header::UserAgent(self.user_agent.clone()));
    request.send()
  }

  pub fn repositories(self, owner: String) { // -> Iter<Repository> ?
    let user = github::user::User::with_login(owner);
    match user.repositories(&self) {
      Ok(repositories) => { 
        for r in repositories {
          println!("{}", r.full_name);
        }
      },
      Err(err) => {
        panic!("Error: {}", err);
      }
    }
  }
}
