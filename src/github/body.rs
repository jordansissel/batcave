use rustc_serialize::json::{Json,Decoder};
use rustc_serialize::Decodable;
use rustc_serialize;
use std::io::Read;

pub fn parse<T: Read, R: rustc_serialize::Decodable, E>(mut r: T) -> Result<R, E> {
  let x = Json::from_reader(&mut r);
  let item = match x {
    Ok(item) => { item },
    Err(err) => { panic!("Err: {}", err); },
  };

  let mut decoder = Decoder::new(item);
  match Decodable::decode(&mut decoder) {
    Ok(decoded) => {
      let repo: R = decoded;
      Ok(repo)
    },
    Err(err) => { panic!("error parsing: {}", err) }
  }
}

