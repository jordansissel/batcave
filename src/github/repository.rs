#[derive(RustcDecodable, Debug)]
pub struct Repository {
  pub id: u64,
  pub name: String,
  pub full_name: String,
  pub description: Option<String>,
  pub fork: bool,

  // There are other fields, I just haven't included them yet.
}

