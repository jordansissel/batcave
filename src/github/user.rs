use github;

#[derive(RustcDecodable, Debug)]
pub struct User {
  id: Option<u64>,
  login: String,
  description: Option<String>,
  avatar_url: Option<String>,
  // There are other fields, I just haven't included them yet.
}

impl User {
  pub fn with_login(login: String) -> Self {
    User {
      id: None,
      login: login,
      description: None,
      avatar_url: None
    }
  }

  pub fn repositories(self, client: &github::client::Client) -> Result<Vec<github::repository::Repository>, github::body::ParseError> {
    let response = client.get(format!("users/{}/repos", self.login)).unwrap();
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
    let user = github::user::User::with_login("elastic".to_string());
    let repositories = match user.repositories(&gh) {
      Ok(r) => r,
      Err(err) => panic!("Failure to fetch repositories: {:?}", err)
    };
    assert!(repositories.iter().any(|r| r.full_name == "elastic/elasticsearch"));
    let repo = match repositories.iter().find(|r| r.full_name == "elastic/elasticsearch") {
      None => panic!("Failure to find elastic/elasticsearch repository"),
      Some(r) => r
    };

    let issues = match repo.issues(&gh) {
      Ok(issues) => issues,
      Err(err) => panic!("Failure to fetch issues for {}: {:?}", repo.full_name, err),
    };

    for issue in issues.iter() {
     println!("Issue {}: {}", issue.number, issue.title);
    }
  }
}
