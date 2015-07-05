use rustc_serialize::json::{self,Json,Decoder};
use rustc_serialize::Decodable;
use std::io::Read;
use std::error::Error;
use std::fmt;

#[derive(Debug)]
pub enum ParseError {
  JSONError(json::ParserError),
  DecoderError(json::DecoderError),
}

impl From<json::ParserError> for ParseError {
  fn from(err: json::ParserError) -> ParseError {
    ParseError::JSONError(err)
  }
}

impl From<json::DecoderError> for ParseError {
  fn from(err: json::DecoderError) -> ParseError {
    ParseError::DecoderError(err)
  }
}

impl Error for ParseError {
  fn description(&self) -> &str {
    match *self {
      ParseError::JSONError(ref err) => err.description(),
      ParseError::DecoderError(ref err) => err.description(),
    }
  }

  fn cause(&self) -> Option<&Error> {
    Some(match *self {
      ParseError::JSONError(ref err) => err as &Error,
      ParseError::DecoderError(ref err) => err as &Error,
    })
  }
}

impl fmt::Display for ParseError {
  fn fmt(&self, format: &mut fmt::Formatter) -> fmt::Result {
    match *self {
      ParseError::JSONError(ref err) => fmt::Display::fmt(err, format),
      ParseError::DecoderError(ref err) => fmt::Display::fmt(err, format),
    }
  }
}

pub fn parse<T: Read, R: Decodable>(mut r: T) -> Result<R, ParseError> {
  let item = try!(Json::from_reader(&mut r));
  let mut decoder = Decoder::new(item);
  let result: R = try!(Decodable::decode(&mut decoder));
  Ok(result)
}

#[cfg(test)]
mod test {
  use std::io::Cursor;
  use github::body::parse;

  #[derive(RustcDecodable, Debug)]
  pub struct SomethingSerializable {
    pub id: u64,
  }

  #[test]
  fn it_should_successfuly_parse_good_data() {
    let io = Cursor::new("{ \"id\": 1234 }".to_string().into_bytes());
    let thing: SomethingSerializable = match parse(io) {
      Ok(i) => i,
      Err(err) => panic!("Parsing should not fail. Error is: {:?}", err),
    };
    assert_eq!(thing.id, 1234u64);
  }

  #[test]
  fn it_should_errors_on_invalid_json() {
    let io = Cursor::new("{ \"id\": 1234 ".to_string().into_bytes());
    let result: Result<SomethingSerializable, _> = parse(io);
    match result {
      Ok(_) => panic!("Parsing should not succeed."),
      Err(_) => { assert!(true) },
    };
  }

  #[test]
  fn it_should_errors_on_invalid_decoding() {
    let io = Cursor::new("{ \"id\": \"hello\" }".to_string().into_bytes());
    let result: Result<SomethingSerializable, _> = parse(io);
    match result {
      Ok(_) => panic!("Parsing should not succeed."),
      Err(_) => { assert!(true) },
    };
  }
}
