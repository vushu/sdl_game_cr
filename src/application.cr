require "sdl"
require "sdl/image"
require "sdl/mix"
module Vubi
  class Application
    @window : SDL::Window | Nil
    @renderer : SDL::Renderer | Nil
    @frame_time : Float64
    @next_time: Float64

    def window
      @window.not_nil!
    end

    def renderer
      @renderer.not_nil!
    end

    def initialize(title : String)
      @title = title
      @running = true
      update_per_secs = 60 + 10 # 10 for smoothness safety margin (gives a max of 70 FPS)
      @frame_time = 1000/update_per_secs
      @next_time = 0;
    end

    def setup_sdl
      SDL.init(SDL::Init::EVERYTHING); at_exit { SDL.quit }
      SDL::IMG.init(SDL::IMG::Init::PNG); at_exit { SDL::IMG.quit }
      SDL::Mix.init(SDL::Mix::Init::FLAC); at_exit { SDL::Mix.quit }
      SDL::Mix.open

      @window = SDL::Window.new(@title, 640, 480)
      @renderer = SDL::Renderer.new(window)
      @window
    end

    def handle_input(event : SDL::Event)
      case event
      when SDL::Event::Quit
        @running = false
      when SDL::Event::Keyboard
        case event.sym
        when .escape?
          @running = false
        when .q?
          @running = false
        end
      end
    end

    def update
      renderer.draw_color = SDL::Color[100, 149, 237, 255]
      renderer.clear
      rect = SDL::Rect.new 0, 0, 100,10
      renderer.draw_color = SDL::Color[255, 149, 237, 255]
      renderer.fill_rect rect
      renderer.present
    end

    private def now
      Time.monotonic.total_milliseconds
    end

    private def poll_inputs
      while event = SDL::Event.poll
        handle_input event
      end
    end



    private def game_loop
      @next_time = now + @frame_time
      while @running

        poll_inputs

        update

        current_time = now

        if current_time < @next_time
          dt_ms = @next_time - current_time
          sleep dt_ms / 1000
        end

        @next_time = now + @frame_time

      end

    end


    def run
      if setup_sdl
        game_loop
      end
    end

  end
end
