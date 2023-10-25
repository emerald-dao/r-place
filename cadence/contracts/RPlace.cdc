// Version - 1
// Goal - Implement all existing feature of r/place as described here: https://en.wikipedia.org/wiki/R/place
// with the addition of:
//   - potentially allowing pixels to be more than just a color

pub contract RPlace {

  pub var totalGrids: UInt64
  pub let allowedHexColors: [String]

  pub resource interface Pixel {
    pub let placedBy: Address
    pub let timePlaced: UFix64
  }

  pub resource ColorPixel: Pixel {
    pub let placedBy: Address
    pub let timePlaced: UFix64
    pub let hexColor: String

    init(placedBy: Address, hexColor: String) {
      self.placedBy = placedBy
      self.timePlaced = getCurrentBlock().timestamp
      self.hexColor = hexColor
    }
  }

  pub resource interface IGrid {
    pub fun place(pixel: @{Pixel}, row: UInt64, column: UInt64)
    pub fun canPlace(user: Address): Bool
  }

  pub resource Grid: IGrid {
    pub let sequence: UInt64
    pub var pixels: @[[{Pixel}?]]
    pub var currentWidth: UInt64
    pub var currentHeight: UInt64

    pub fun place(pixel: @{Pixel}, row: UInt64, column: UInt64) {
      pre {
        row < self.currentWidth: "Cannot select an unavailable row."
        column < self.currentHeight: "Cannot select an unavailable column."
        pixel.getType() == Type<@ColorPixel>(): "This Grid only accepts ColorPixels."
      }

      let oldPixel: @{Pixel}? <- self.pixels[row][column] <- pixel 
      // maybe do something with oldPixel if it's not `nil`
      destroy oldPixel
    }

    pub fun canPlace(user: Address): Bool {
      return true
    }

    pub fun growGrid(newWidth: UInt64, newHeight: UInt64) {
      // do we care about checking against actual dimensions of `self.pixels`?
      pre {
        newWidth > self.currentWidth: "Cannot set a new width that is smaller than the current one."
        newHeight > self.currentHeight: "Cannot set a new height that is smaller than the current one."
      }
      self.currentWidth = newWidth
      self.currentHeight = newHeight
    }

    init(emptyGrid: @[[{Pixel}?]], initialWidth: UInt64, initialHeight: UInt64) {
      self.sequence = RPlace.totalGrids
      self.pixels <- emptyGrid
      self.currentWidth = initialWidth
      self.currentHeight = initialHeight

      RPlace.totalGrids = RPlace.totalGrids + 1
    }

    destroy() {
      destroy self.pixels
    }
  }

  pub resource interface Identity {}

  pub resource Collection: Identity {
    pub let grids: @{UInt64: Grid}

    pub fun deposit(grid: @Grid) {
      self.grids[grid.uuid] <-! grid
    }

    pub fun destroyGrid(gridUuid: UInt64) {
      destroy self.grids.remove(key: gridUuid)
    }

    pub fun getIDs(): [UInt64] {
      return self.grids.keys
    }

    init() {
      self.grids <- {}
    }

    destroy() {
      destroy self.grids
    }
  }

  pub fun createGrid(emptyGrid: @[[{Pixel}?]], initialWidth: UInt64, initialHeight: UInt64): @Grid {
    return <- create Grid(emptyGrid: <- emptyGrid, initialWidth: initialWidth, initialHeight: initialHeight)
  }

  pub fun createCollection(): @Collection {
    return <- create Collection()
  }

  pub fun createColorPixel(identity: &{Identity}, hexColor: String): @ColorPixel {
    pre {
      RPlace.allowedHexColors.contains(hexColor): "You cannot use this color."
    }
    return <- create ColorPixel(placedBy: identity.owner!.address, hexColor: hexColor)
  }

  init() {
    self.totalGrids = 0
    self.allowedHexColors = [

    ]
  }
}