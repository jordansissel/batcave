

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
