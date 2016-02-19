
import Effects exposing (Never)
import AbacusTrainer exposing( init, effective_update, view, window_size )
import StartApp
import Task


app =
  StartApp.start
    { init = init externalSeed
    , update = effective_update
    , view = view
    , inputs = [ window_size ]
    }


main =
  app.html



port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks


port externalSeed : Int