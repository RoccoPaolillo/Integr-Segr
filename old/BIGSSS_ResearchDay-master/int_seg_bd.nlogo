globals [
  percent-similar-eth
  percent-similar-val
]

patches-own [
 uti-eth
 uti-val
]

turtles-own [
  ethnicity
similar-ethnics
  total-neighbors
  ethnic-utility
  value-utility
  similar-value
  total-utility
]

to setup
 ; random-seed 100
  clear-all
  ask patches [set pcolor white
    if random 100 < density [sprout 1 [

    ;  set shape "square"
     ifelse random 100 < fraction_blue
      [set ethnicity "local"
       set color blue
        set shape ifelse-value (random 100 < circle_blue) ["circle"]["square"]
      ]

      [set ethnicity "minority"
       set color orange
        set shape ifelse-value (random 100 < circle_orange) ["circle"]["square"]
      ]
      ]
    ]
  ]
 update-turtles
 update-globals
 ; random-seed new-seed
  reset-ticks
end

to go
  update-turtles     ; attributes and weights of turtles
  move-turtles       ; relocation decision of turtles
  update-globals     ; global reportes
tick
end




to move-turtles                                                    ; choice for each turtle
  ask turtles [

   let ethnicity-myself ethnicity
   let shape-myself shape
   let proba 0


   let alternative one-of patches with [not any? turtles-here]
   let options (patch-set alternative patch-here)              ; set of alternatives for each turtle as local procedure for current agent. The set of choice includes current patch and one random empty patch

    ask options [                   ; for each of two alternatives value utility and ethnic utility is calculated (see below report)

      let xe count (turtles-on neighbors) with [ethnicity = ethnicity-myself]    ; number of similar ethnics in neighborhood (Moore 8 neighborhood)
      let xv count (turtles-on neighbors) with [ shape = shape-myself]  ; number of value similars in the neighborhood.
                                                                                                    ; Value similars are those whose ethnic weight (importance of ethnic characteristic in choice relocation)
                                                                                                    ; falls  into the agent's interval.
      let n count (turtles-on neighbors)                                         ; total number turtles in neighborhood (Moore 8 neighborhood)

      set uti-eth ifelse-value (shape-myself = "square") [utility xe n i_e_sq] [utility xe n i_e_cl]      ; ethnic utility is calculated (proportion of similar ethnics, see below report for function)
      set uti-val ifelse-value (shape-myself = "square") [utility  xv n i_v_sq][utility xv n i_v_cl]

    ]

 set proba  (1 / (1 + exp( ( ( beta-ie *  [uti-eth] of patch-here) + (beta-iv * [uti-val] of patch-here))  -  (( beta-ie *  [uti-eth] of alternative) + (beta-iv *   [uti-val] of alternative)) ) ) )

 if random-float 1 < proba [move-to alternative]     ; final decision to relocate: if probability calculated as above with logistic function is higher than random-float number [0,1], then the agent relocates

  ]


end

to update-turtles                           ; updates of preferences of turtles

  ask turtles[

    set similar-ethnics (count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself])                              ; these are just to have reporters to check in the simulation
    set similar-value (count (turtles-on neighbors) with [shape = [shape] of myself])
    set total-neighbors (count turtles-on neighbors)
    set ethnic-utility  ifelse-value (shape = "square") [utility similar-ethnics total-neighbors i_e_sq] [utility similar-ethnics total-neighbors i_e_cl]
    set value-utility  ifelse-value (shape = "square") [utility  similar-value total-neighbors i_v_sq][utility similar-value total-neighbors i_v_cl]
    set total-utility (ethnic-utility + value-utility)

  ]
end

to update-globals

  let tot-ethnics sum [ similar-ethnics ] of turtles               ; reporters for emerging properties: ethnic  and value segregation
  let tot-value sum [ similar-value ] of turtles
 let tot-neighbors sum [ total-neighbors ] of turtles
  set percent-similar-val (tot-value / tot-neighbors) * 100
  set percent-similar-eth (tot-ethnics / tot-neighbors) * 100
end


to-report utility [a b c]   ; the three types of utility functions: threshold, single-peaked, linear + constant

  if utility_function = "threshold"
[ report ( ifelse-value (a >= (b * c))
        [ 1 ][ 0 ]
 )
  ]


if utility_function = "single-peaked"  # not symmetric
[ report ( ifelse-value (b = 0) [0]
     [ifelse-value (a = (b * c)) [1]
       [ifelse-value (a < (b * c))
         [ precision (a / (b * c))  3
         ][ precision ( c + (((1 -  (a / b)) * (1 - c)) / (1 - c))) 3 ]
       ]
     ]
 )
  ]


if utility_function = "linear-const"
[ report ( ifelse-value (b = 0) [ifelse-value (c = 0) [1][0]]
     [ifelse-value (a = (b * c)) [1]
       [ifelse-value (a < (b * c))
         [ precision (a / (b * c))  3
         ][ 1 ]
       ]
     ]
 )
  ]

end
@#$#@#$#@
GRAPHICS-WINDOW
206
10
663
468
-1
-1
8.804
1
10
1
1
1
0
1
1
1
-25
25
-25
25
0
0
1
ticks
30.0

SLIDER
79
10
200
43
density
density
0
99
70.0
1
1
NIL
HORIZONTAL

SLIDER
78
49
200
82
fraction_blue
fraction_blue
50
100
80.0
1
1
NIL
HORIZONTAL

BUTTON
578
479
641
512
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
645
479
708
512
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
683
326
940
470
segregation-global
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"eth-seg" 1.0 0 -5825686 true "" "plot percent-similar-eth"
"val-seg" 1.0 0 -10899396 true "" "plot percent-similar-val"

TEXTBOX
7
16
69
51
population parameters
11
0.0
1

SLIDER
3
91
95
124
circle_blue
circle_blue
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
97
92
201
125
circle_orange
circle_orange
0
100
50.0
1
1
NIL
HORIZONTAL

MONITOR
256
479
318
524
circle_blue
count turtles with [shape = \"circle\" and ethnicity = \"local\"] / count turtles
2
1
11

MONITOR
322
479
394
524
square_bue
count turtles with [shape = \"square\" and  ethnicity = \"local\"] / count turtles
2
1
11

MONITOR
398
479
478
524
circle_orange
count turtles with [shape = \"circle\" and ethnicity = \"minority\"] / count turtles
2
1
11

MONITOR
479
479
568
524
square_orange
count turtles with [shape = \"square\" and ethnicity = \"minority\"] / count turtles
2
1
11

MONITOR
252
577
327
622
local/minority
count turtles with [ethnicity = \"local\"] / count turtles
2
1
11

MONITOR
332
579
392
624
circle_%
count turtles with [shape = \"circle\"] / count turtles
2
1
11

PLOT
683
169
938
319
circle-blue
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"ethnic" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"c\" and ethnicity = \"local\"]"
"value" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"c\" and ethnicity = \"local\"]"
"density" 1.0 0 -7500403 true "" "plot mean [count (turtles-on neighbors)] of turtles with [first shape = \"c\" and ethnicity = \"local\"] / 8"
"uti-eth" 1.0 0 -2674135 true "" "plot mean [ethnic-utility] of turtles with [first shape = \"c\" and ethnicity = \"local\"]"
"uti-val" 1.0 0 -13345367 true "" "plot mean [value-utility] of turtles with [first shape = \"c\" and ethnicity = \"local\"]"

PLOT
682
10
941
160
square-blue
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"ethnic" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"s\" and ethnicity = \"local\"]"
"value" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"s\"  and ethnicity = \"local\"]"
"dennsity" 1.0 0 -7500403 true "" "plot mean [count (turtles-on neighbors)] of turtles with [first shape = \"s\" and ethnicity = \"local\"]  / 8"
"uti-eth" 1.0 0 -2674135 true "" "plot mean [ethnic-utility] of turtles with [first shape = \"s\" and ethnicity = \"local\"]"
"uti-val" 1.0 0 -13345367 true "" "plot mean [value-utility] of turtles with [first shape = \"s\" and ethnicity = \"local\"]"

SLIDER
105
197
199
230
i_e_sq
i_e_sq
0
1
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
4
197
99
230
i_v_sq
i_v_sq
0
1
0.5
0.1
1
NIL
HORIZONTAL

PLOT
955
10
1185
160
square-orange
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"eth" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"s\" and ethnicity = \"minority\"]"
"val" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"s\" and ethnicity = \"minority\"]"
"uti-eth" 1.0 0 -2674135 true "" "plot mean [ethnic-utility] of turtles with [first shape = \"s\" and ethnicity = \"minority\"]"
"uti-val" 1.0 0 -13345367 true "" "plot mean [value-utility] of turtles with [first shape = \"s\" and ethnicity = \"minority\"]"
"density" 1.0 0 -7500403 true "" "plot mean [count (turtles-on neighbors)] of turtles with [first shape = \"s\" and ethnicity = \"minority\"] / 8"

SLIDER
101
267
197
300
i_e_cl
i_e_cl
0
1
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
3
265
95
298
i_v_cl
i_v_cl
0
1
0.5
0.1
1
NIL
HORIZONTAL

PLOT
957
170
1191
320
circle-orange
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"ethnic" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"c\" and ethnicity = \"minority\"]"
"value" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"c\" and ethnicity = \"minority\"]"
"density" 1.0 0 -7500403 true "" "plot mean [count (turtles-on neighbors)] of turtles with [first shape = \"c\" and ethnicity = \"minority\"] / 8"
"uti-eth" 1.0 0 -2674135 true "" "plot mean [ethnic-utility] of turtles with [ first shape = \"c\" and ethnicity = \"minority\"]"
"val-eth" 1.0 0 -13345367 true "" "plot mean [value-utility] of turtles with [first shape = \"c\" and ethnicity = \"minority\"]"

PLOT
960
323
1195
473
utility-global
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"uti-eth" 1.0 0 -2674135 true "" "plot mean [ethnic-utility] of turtles"
"uti-val" 1.0 0 -13345367 true "" "plot mean [value-utility] of turtles"
"uti-tot" 1.0 0 -7500403 true "" "plot mean [total-utility] of turtles"

TEXTBOX
59
168
154
186
squared population
11
0.0
1

TEXTBOX
63
240
145
258
circle population
11
0.0
1

CHOOSER
32
334
170
379
utility_function
utility_function
"threshold" "single-peaked" "linear-const"
1

MONITOR
1187
10
1250
55
eth-sq-bl
mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"s\" and ethnicity = \"local\"]
2
1
11

MONITOR
1187
60
1252
105
eth-sq-or
mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"s\" and ethnicity = \"minority\"]
2
1
11

MONITOR
1252
10
1312
55
val-sq-bl
mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"s\"  and ethnicity = \"local\"]
2
1
11

MONITOR
1255
59
1318
104
val-sq-or
mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"s\"  and ethnicity = \"minority\"]
2
1
11

MONITOR
1189
110
1250
155
den_sq_bl
mean [count (turtles-on neighbors)] of turtles with [first shape = \"s\" and ethnicity = \"local\"] / 8
2
1
11

MONITOR
1257
109
1319
154
den_sq_or
mean [count (turtles-on neighbors)] of turtles with [first shape = \"s\" and ethnicity = \"minority\"] / 8
2
1
11

MONITOR
1318
10
1381
55
ut-et-sq-bl
mean [ethnic-utility] of turtles with [first shape = \"s\" and ethnicity = \"local\"]
2
1
11

MONITOR
1321
60
1387
105
ut-et-sq-or
mean [ethnic-utility] of turtles with [first shape = \"s\" and ethnicity = \"minority\"]
2
1
11

MONITOR
1386
10
1452
55
ut-vl-sq-bl
mean [value-utility] of turtles with [first shape = \"s\" and ethnicity = \"local\"]
2
1
11

MONITOR
1391
58
1453
103
ut-vl-sq-or
mean [value-utility] of turtles with [first shape = \"s\" and ethnicity = \"minority\"]
2
1
11

MONITOR
1194
170
1252
215
eth-cl-bl
mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"c\" and ethnicity = \"local\"]
2
1
11

MONITOR
1255
170
1312
215
val-cl-bl
mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"c\"  and ethnicity = \"local\"]
2
1
11

MONITOR
1318
170
1385
215
ut-et-cl-bl
mean [ethnic-utility] of turtles with [first shape = \"c\" and ethnicity = \"local\"]
2
1
11

MONITOR
1389
170
1454
215
ut-vl-cl-bl
mean [value-utility] of turtles with [first shape = \"c\" and ethnicity = \"local\"]
2
1
11

MONITOR
1195
220
1252
265
eth-cl-or
mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"c\" and ethnicity = \"minority\"]
2
1
11

MONITOR
1255
219
1313
264
val-cl-or
mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"c\"  and ethnicity = \"minority\"]
2
1
11

MONITOR
1318
217
1386
262
ut-et-cl-or
mean [ethnic-utility] of turtles with [first shape = \"c\" and ethnicity = \"minority\"]
2
1
11

MONITOR
1389
218
1456
263
ut-vl-cl-or
mean [value-utility] of turtles with [first shape = \"c\" and ethnicity = \"minority\"]
2
1
11

MONITOR
1196
268
1252
313
den_cl_bl
mean [count (turtles-on neighbors)] of turtles with [first shape = \"c\" and ethnicity = \"local\"] / 8
2
1
11

MONITOR
1256
266
1314
311
den_cl_or
mean [count (turtles-on neighbors)] of turtles with [first shape = \"c\" and ethnicity = \"minority\"] / 8
2
1
11

MONITOR
1200
323
1257
368
eth-seg
percent-similar-eth
2
1
11

MONITOR
1201
373
1258
418
val-seg
percent-similar-val
2
1
11

MONITOR
1263
322
1320
367
eth-uti
mean [ethnic-utility] of turtles
2
1
11

MONITOR
1263
372
1320
417
val-uti
mean [value-utility] of turtles
2
1
11

SLIDER
20
418
177
451
beta-ie
beta-ie
0
100
55.0
1
1
NIL
HORIZONTAL

SLIDER
21
454
178
487
beta-iv
beta-iv
0
100
55.0
1
1
NIL
HORIZONTAL

PLOT
806
482
1094
632
segregation_value-group
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"eth-circle" 1.0 0 -16777216 true "" "plot mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\"]"
"eth-square" 1.0 0 -7500403 true "" "plot mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\"]"
"val-circle" 1.0 0 -955883 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\"]"
"val-squared" 1.0 0 -10146808 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\"]"

MONITOR
399
577
492
622
circle_orange_n
count turtles with [shape = \"circle\" and ethnicity = \"minority\"]
2
1
11

MONITOR
500
579
595
624
circle_blue_n
count turtles with [shape = \"circle\" and ethnicity = \"local\"]
2
1
11

MONITOR
397
626
495
671
square_orange_n
count turtles with [shape = \"square\" and ethnicity = \"minority\"]
2
1
11

MONITOR
500
626
595
671
square_blue_n
count turtles with [shape = \"square\" and ethnicity = \"local\"]
2
1
11

MONITOR
249
629
315
674
orange_n
count turtles with [ ethnicity = \"minority\"]
2
1
11

MONITOR
321
628
390
673
blue_n
count turtles with [ ethnicity = \"local\"]
2
1
11

TEXTBOX
198
488
253
520
% population
11
0.0
1

MONITOR
256
527
331
572
%circle_blue
count turtles with [shape = \"circle\" and ethnicity = \"local\"] / count turtles with [ethnicity = \"local\"]
2
1
11

MONITOR
334
527
421
572
%square_blue
count turtles with [shape = \"square\" and ethnicity = \"local\"] / count turtles with [ethnicity = \"local\"]
2
1
11

MONITOR
507
527
597
572
%circle_orange
count turtles with [shape = \"circle\" and ethnicity = \"minority\"] / count turtles with [ethnicity = \"minority\"]
2
1
11

MONITOR
599
527
695
572
%square_orange
count turtles with [shape = \"square\" and ethnicity = \"minority\"] / count turtles with [ethnicity = \"minority\"]
2
1
11

TEXTBOX
189
540
257
558
% in majority
11
0.0
1

TEXTBOX
434
542
504
560
% in minority
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

In the original Schelling's model of residential segregation, agents represent households divided into two ethnic groups who reside in a location as long as the proportion of similar ones is not below a desired threshold. Schelling demonstrated how residential segregation can emerge as unintended consequence of people trying to satisfy their homophily preferences based on a "twofold, exhaustive and recognizable distinction" (p.488) in spatial constaints such as density population.
In our previous paper (Paolillo & Lorenz, 2018), we explored the consequence on Schelling dynamics if similarity is not defined in these terms, but as an attribute independent of and evenly shared between ethnic groups. We conceptualized it as value for tolerance and divided the population into agents following ethnic homophily preferences and others following value homophily preferences, plus the role of relative  group sizes.
This simulation is an extension of our previous work, in particular trying to fit the rational paradigm of discrete choices and random utility models. Both ethnic and value homophily contribute to define the desirability of neighborhoods. Additionally, I want to compare the consequence of different utility functional forms. While Schelling's  dynamics are enacted by a threshold function, recent studies focus on more detailed single-peaked functions (Bruch & Mare, 2006; Zhang, 2004). I am interested in what would be the consequences of different utility functions (threshold vs single-peaked) with definition of utility based on ethnic and value homophily.

Simulation for the BIGSSS-Research Day
Project fuded by  MSCA - 713639

## HOW IT WORKS

Agents represents households relocating in a city and are divided along two dimensions:
- ethnicity: color blue vs orange, independent of value orientation
- value orientation: square vs circle, independent of ethnicity

In a very simplified way, this represent how people can share different values and belong to different categories potentially independent of attributed ethnic membership and that can serve to cross ethnic boundaries and define membership in diverse societies (Wimmer, 2009). In this study, this is applied to definition of homophily preferences within residential choice. 
At each step an agent compares its current location with another potential location and makes a choice depending on the desired attributes of a neighborhood. Agents move asynchronously: one is selected randomly, makes a choice, and then the next agents move; all agents eventually make a choice.
Utility, i.e. desirability of a neighborhood is based on the linear combination of two attributes: the proportion of people of the same ethnicity plus the proportion of people of same value orientation in a neighborhood, i.e. U: ethnic composition + value composition. The desired concentration of similar ethnics or similar value depends on value orientation of agents.
Probability to select a neighborhood fits the discrete choice models and random utility models, which assume that although people maximize their utility, their choice can be influenced by other attributes of the option and as a matter of fact, not always the best option is taken, so that people vary for their random behavior U: ethnic composition + value composition + random-term
In the model, this is translated into a logit binary choice (Train, 2009) and the probability for an agent to relocate to the alternative location is computed as:
P: 1 / 1 + exp(Utility_current - U_alternative).
Following Train (2009, p. 39), this is a simplification of P(alternative)=exp(U_alternative)/exp(U_current) + exp(U_alternative) and per se the logit model is the basis for the mother mother of other models, including the multinomial logit (Train, 2009; Hess, Daly, Batley, 2018) 


## HOW TO USE IT

Population parameters:
- density of society
- fraction_blue: relative group sizes local population / minority population
- circle_blue, circle_orange: ratio of value oriented within each group

- Attributes of utility: desired concentration of similar ethnics (i_e) and similar value (i_v) for value squared population (sq) and value circle population (cl). This means that agents differ in their utility according to the value orientation, the equivalent of interaction in regression models (e.g. ethnicity*political ideology).

- Utility function: the shape of utility function, i.e. how agents assess the utility-desirability of a neighborhood depending on the proportion of similar ones:
 - threshold: as original Schelling: all levels equal or above the desired proportion have same utility 1
 - single-peaked: the max utility is at desired concentration, levels below are linearly increased as they approximate, decreasing according to how far they get from the ideal point
- linear+const: the utility is linearly increasing until the ideal concentration, constant at 1 for the levels above. This option is potentially excluded from the studies

- lambda: randomness in the model, i.e. how much the choice of agents is totally random (each option has equal 0.50 probability to be selected) (lambda = 0) or choice due to systematic differences in utility between current location and alternative one (ethnic + value) (high levels of lambda)


## THINGS TO NOTICE

- Ethnic segregation
- Value segregation
- Increment of utility

## CREDITS AND REFERENCES

Schelling, T. C. (1969). Models of segregation. The American Economic Review, 59(2), 488-493
Paolillo, R., & Lorenz, J. (2018). How different homophily preferences mitigate and spur ethnic and value segregation: Schelling’s model extended. Advances in Complex Systems, 21(06n07), 1850026.
Bruch, E. E., & Mare, R. D. (2006). Neighborhood choice and neighborhood change. American Journal of sociology, 112(3), 667-709.
Zhang, J. (2004). Residential segregation in an all-integrationist world. Journal of Economic Behavior & Organization, 54(4), 533-550.
Wimmer, A. (2008). The making and unmaking of ethnic boundaries: A multilevel process theory. American journal of sociology, 113(4), 970-1022.
Train, K. E. (2009). Discrete choice methods with simulation. Cambridge university press.
Hess, S., Daly, A., & Batley, R. (2018). Revisiting consistency with random utility maximisation: theory and implications for practical work. Theory and Decision, 84(2), 181-204.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [total-utility] of turtles</metric>
    <metric>mean [ethnic-utility] of turtles</metric>
    <metric>mean [value-utility] of turtles</metric>
    <metric>mean [count (turtles-on neighbors)]  of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors)] of turtles with [count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean  [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors)]  of turtles with [count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [total-utility] of turtles  with [ethnicity = "local"]</metric>
    <metric>mean [ethnic-utility] of turtles with [ethnicity = "local"]</metric>
    <metric>mean [value-utility] of turtles with [ethnicity = "local"]</metric>
    <metric>mean [count (turtles-on neighbors)]  of turtles  with [ethnicity = "local"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors)] of turtles with [count (turtles-on neighbors) &gt;= 1 and ethnicity = "local"]</metric>
    <metric>mean  [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors)]  of turtles with [count (turtles-on neighbors) &gt;= 1 and ethnicity = "local"]</metric>
    <metric>mean [total-utility] of turtles  with [ethnicity = "minority"]</metric>
    <metric>mean [ethnic-utility] of turtles with [ethnicity = "minority"]</metric>
    <metric>mean [value-utility] of turtles with [ethnicity = "minority"]</metric>
    <metric>mean [count (turtles-on neighbors)]  of turtles  with [ethnicity = "minority"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors)] of turtles with [count (turtles-on neighbors) &gt;= 1 and ethnicity = "minority"]</metric>
    <metric>mean  [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors)]  of turtles with [count (turtles-on neighbors) &gt;= 1 and ethnicity = "minority"]</metric>
    <metric>mean [total-utility] of turtles  with [shape = "square"]</metric>
    <metric>mean [ethnic-utility] of turtles with [shape = "square"]</metric>
    <metric>mean [value-utility] of turtles with [shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors)]  of turtles  with [shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors)] of turtles with [count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean  [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors)]  of turtles with [count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [total-utility] of turtles  with [shape = "circle"]</metric>
    <metric>mean [ethnic-utility] of turtles with [shape = "circle"]</metric>
    <metric>mean [value-utility] of turtles with [shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)]  of turtles  with [shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors)] of turtles with [count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean  [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors)]  of turtles with [count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [total-utility] of turtles  with [ethnicity = "local" and shape = "circle"]</metric>
    <metric>mean [ethnic-utility] of turtles with [ethnicity = "local" and shape = "circle"]</metric>
    <metric>mean [value-utility] of turtles with [ethnicity = "local" and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)]  of turtles  with [ethnicity = "local" and shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors)] of turtles with [count (turtles-on neighbors) &gt;= 1 and ethnicity = "local" and shape = "circle"]</metric>
    <metric>mean  [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors)]  of turtles with [count (turtles-on neighbors) &gt;= 1 and ethnicity = "local" and shape = "circle"]</metric>
    <metric>mean [total-utility] of turtles  with [ethnicity = "minority" and shape = "circle"]</metric>
    <metric>mean [ethnic-utility] of turtles with [ethnicity = "minority" and shape = "circle"]</metric>
    <metric>mean [value-utility] of turtles with [ethnicity = "minority" and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)]  of turtles  with [ethnicity = "minority" and shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors)] of turtles with [count (turtles-on neighbors) &gt;= 1 and ethnicity = "minority" and shape = "circle"]</metric>
    <metric>mean  [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors)]  of turtles with [count (turtles-on neighbors) &gt;= 1 and ethnicity = "minority" and shape = "circle"]</metric>
    <metric>mean [total-utility] of turtles  with [ethnicity = "local" and shape = "square"]</metric>
    <metric>mean [ethnic-utility] of turtles with [ethnicity = "local" and shape = "square"]</metric>
    <metric>mean [value-utility] of turtles with [ethnicity = "local" and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors)]  of turtles  with [ethnicity = "local" and shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors)] of turtles with [count (turtles-on neighbors) &gt;= 1 and ethnicity = "local" and shape = "square"]</metric>
    <metric>mean  [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors)]  of turtles with [count (turtles-on neighbors) &gt;= 1 and ethnicity = "local" and shape = "square"]</metric>
    <metric>mean [total-utility] of turtles  with [ethnicity = "minority" and shape = "square"]</metric>
    <metric>mean [ethnic-utility] of turtles with [ethnicity = "minority" and shape = "square"]</metric>
    <metric>mean [value-utility] of turtles with [ethnicity = "minority" and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors)]  of turtles  with [ethnicity = "minority" and shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors)] of turtles with [count (turtles-on neighbors) &gt;= 1 and ethnicity = "minority" and shape = "square"]</metric>
    <metric>mean  [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors)]  of turtles with [count (turtles-on neighbors) &gt;= 1 and ethnicity = "minority" and shape = "square"]</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fraction_blue">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="circle_blue">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="circle_orange">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="i_e_sq">
      <value value="0"/>
      <value value="0.3"/>
      <value value="0.5"/>
      <value value="0.7"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="i_v_sq">
      <value value="0"/>
      <value value="0.3"/>
      <value value="0.5"/>
      <value value="0.7"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="i_e_cl">
      <value value="0"/>
      <value value="0.3"/>
      <value value="0.5"/>
      <value value="0.7"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="i_v_cl">
      <value value="0"/>
      <value value="0.3"/>
      <value value="0.5"/>
      <value value="0.7"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta-ie">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta-iv">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="utility_function">
      <value value="&quot;single-peaked&quot;"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
