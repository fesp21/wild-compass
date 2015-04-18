require "wild/compass/decorator/story"

class JarDecorator < ApplicationDecorator

  include Wild::Compass::Decorator::Story

  decorates :jar

  delegate_all

end
