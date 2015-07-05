use github;

#[derive(RustcDecodable, Debug)]
pub struct Repository {
  pub id: u64,
  //pub name: String,
  pub full_name: String,
  pub description: Option<String>,
  pub fork: bool,
}

impl Repository {
  pub fn issues(&self, client: &github::client::Client) -> Result<Vec<github::issue::Issue>, github::body::ParseError> {
    let response = client.get(format!("repos/{}/issues", self.full_name)).unwrap();
    let result: Result<Vec<github::issue::Issue>, github::body::ParseError> = github::body::parse(response);
    result
  }
}

