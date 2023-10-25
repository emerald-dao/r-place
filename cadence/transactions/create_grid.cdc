import RPlace from "../contracts/RPlace.cdc"

transaction() {

  prepare(signer: AuthAccount) {
    let thing: [[AnyStruct]] = []
    log(thing[0])
  }

  execute {

  }
}