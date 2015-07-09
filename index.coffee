module.exports = (protractor, global) ->

  if typeof global is "undefined" or typeof protractor is "undefined"
    throw new Error("Trying to load protractor-extras but protractor can't be found.")

  By = global.by
  ElementFinder = protractor.ElementFinder
  ElementArrayFinder = protractor.ElementArrayFinder

  # All pages should extend this class
  global.Page = class
    get: (what) ->
      return element(By.what.apply(this, arguments))
    which: (which) ->
      return element(By.which.apply(this, arguments))
    all: (what) ->
      return element.all(By.what(what))
    select: (selector) ->
      return element(By.css(selector))

  # Add By.what("selector") method to select elements by the "what" attribute: <img what="my element" />
  By.addLocator "what", (what) ->
    if arguments.length is 4
      parent = arguments[2]
      firstOnly = arguments[3]
    else
      parent = arguments[1]
      firstOnly = false
    elements = $(parent or document).find("[what=\"" + what + "\"]")
    return elements.first() if firstOnly
    return elements

  # Add convenience method element.get("selector"), short for element(By.what("selector"))
  ElementFinder.prototype.get = (what) ->
    if typeof what is "string"
      return @element(By.what(what))
    else
      return @element(what)

  # Add convenience method element.select("selector"), short for element(By.css("selector"))
  ElementFinder.prototype.select = (selector) ->
    return @element(By.css(selector))

  # Add convenience method element.parent(), short for element(By.xpath('..'))
  ElementFinder.prototype.parent = (what) ->
    return @element(By.xpath(".."))

  # Add convenience method element.all("selector"), short for element(By.what("selector"))
  originalElementAllMethod = ElementFinder.prototype.all
  ElementFinder.prototype.all = (what) ->
    if typeof what is "string"
      return @all(By.what(what))
    else
      return originalElementAllMethod.apply(this, arguments)

  # Add convenience method elements.which("specific element")
  ElementArrayFinder.prototype.which = (which) ->
    filter = (element) ->
      return element.getAttribute("which").then (value) ->
        return which is value
    return @filter(filter).toElementFinder_()

