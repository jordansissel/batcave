use github;

#[derive(RustcDecodable, Debug)]
pub struct User {
  id: Option<u64>,
  name: String,
  description: Option<String>,
  avatar: Option<String>,
  // There are other fields, I just haven't included them yet.
}

impl User {
  pub fn with_name(name: String) -> Self {
    User {
      id: None,
      name: name,
      description: None,
      avatar: None
    }
  }

  pub fn repositories(self, client: github::client::Client) -> Result<Vec<github::repository::Repository>, github::body::ParseError> {
    let response = client.get(format!("users/{}/repos", self.name)).unwrap();
    let result: Result<Vec<github::repository::Repository>, github::body::ParseError> = github::body::parse(response);
    result
  }
}

#[cfg(test)]
mod test {
  use github;

  #[test]
  fn test_user_repositories() {
    let gh = github::client::Client::new();
    let user = github::user::User::with_name("elastic".to_string());
    let repositories = user.repositories(gh);
    assert!(repositories.ok().expect("whatever").iter().any(|r| r.full_name == "elastic/elasticsearch"))
  }
}
