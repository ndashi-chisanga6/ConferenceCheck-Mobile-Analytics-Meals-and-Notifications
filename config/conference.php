<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Session capacity warning threshold
    |--------------------------------------------------------------------------
    |
    | Fraction of a session's capacity at which organisers receive a
    | "filling up" push alert. Crossing full capacity always triggers an
    | over-capacity alert regardless of this value.
    |
    */

    'capacity_warning_threshold' => (float) env('CAPACITY_WARNING_THRESHOLD', 0.9),

];
