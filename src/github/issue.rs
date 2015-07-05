use github;

#[derive(RustcDecodable, Debug)]
pub enum IssueState {
  Open(String),
  Closed(String),
}

#[derive(RustcDecodable, Debug)]
pub struct Issue {
  pub number: u64,
  pub state: String, //IssueState,
  pub title: String,
  pub body: String,

  // The 'user' object that comes back uses 'login' as the field name.
  //pub user: github::user::User,
  pub labels: Vec<github::label::Label>,
}

