globals [
  epsilon
]


turtles-own [
  my-neighbours
  n-of-neighbours
  standing?
  awkwardness  ;; 이웃과의 행동 불일치 정도
  belief
  threshold
  P
  pressure
]

;;;;;;;;;;;;;;;;;;;;;;;
;;; SETUP PROCEDURES ;;;
;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  setup-turtles
  set external-pressure 0.1
  set epsilon 0.001
  reset-ticks
end

to setup-turtles
  set-default-shape turtles "person"
  clear-turtles

  let total-patches count patches  ;; 사용 가능한 패치 수 확인
  if total-patches < 108 [
    user-message "패치 수가 108보다 적어 에이전트를 모두 배치할 수 없습니다."
    stop
  ]

  let selected-patches n-of 108 patches
  ask selected-patches [
    sprout 1 [
      set shape "circle"
      set standing? false  ;; 초기 상태: 앉아 있음
      set color gray        ;; 기본 색상: 회색
      set awkwardness 0
      set belief random-float 1
      set threshold 0.5
    ]
  ]

  ;; 각 에이전트의 이웃 설정
  ask turtles [setup-neighbourhood]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TURTLES' PROCEDURES ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-neighbourhood
  set my-neighbours turtles-on (neighbors with [pycor >= [pycor] of myself])
  if cone-length > 1 [
    set my-neighbours (turtle-set my-neighbours
      other turtles with [
       (ycor - [ycor] of myself  >= xcor - [xcor] of myself)
        and
       (ycor - [ycor] of myself  >= [xcor] of myself - xcor)
       and
       (ycor <= [ycor] of myself + cone-length)
      ]
    )
  ]
  set n-of-neighbours count my-neighbours
end

to-report neighbor-pressure [agent]
  let my-ycor [ycor] of agent  ;; 기준 행위자의 y 좌표
  let my-xcor [xcor] of agent  ;; 기준 행위자의 x 좌표

  ;; 기준 행위자의 양옆 패치 선택
  let relevant-patches patches with [
    pycor = my-ycor and abs(pxcor - my-xcor) = 1
  ]

  ;; 양옆 이웃이 있는 경우 압력 계산
  if any? relevant-patches [
    let neighbor turtles-on relevant-patches  ;; 해당 패치에 있는 에이전트
    if any? neighbor [
      let state-sum sum [ifelse-value standing? [1] [-1]] of neighbor  ;; 이웃 상태 합산
      let neighbor-size count neighbor  ;; 이웃 수 계산
      let avg-state state-sum / neighbor-size  ;; 평균 상태 계산

      ;; 가중치 1/2 적용
      let weighted-pressure avg-state * 0.5

      report weighted-pressure  ;; 가중치가 적용된 압력 반환
    ]
  ]

  ;; 이웃이 없으면 0 반환
  report 0
end






to-report funnel-pressure [agent]
  let my-ycor [ycor] of agent  ;; 에이전트의 y 좌표
  let my-xcor [xcor] of agent  ;; 에이전트의 x 좌표
  let funnel 0                 ;; Funnel Pressure 초기값
  let norm 0                   ;; 가중치 합산값 초기값

  ;; 거리별로 반복
  let dist 1
  while [dist <= cone-length] [
    ;; 현재 거리 dist에서 볼 수 있는 패치
    let row-patches patches with [pycor = my-ycor + dist]  ;; 상위 행의 패치 선택
    let relevant-patches row-patches with [
      abs(pxcor - my-xcor) <= dist  ;; 좌우로 dist만큼 확장된 패치
    ]

    ;; 거리별 이웃 상태 합산
    if any? relevant-patches [
      let neighbor turtles-on relevant-patches  ;; 해당 패치에 있는 에이전트
      if any? neighbor [
        let state-sum sum [ifelse-value standing? [1] [-1]] of neighbor  ;; 이웃 상태 합산
        let neighbor-size count neighbor          ;; 이웃의 수 (2x + 1에 해당)
        let avg-state state-sum / neighbor-size    ;; 이웃 상태의 평균값

        ;; Funnel Pressure 계산
        let weight 1 / (dist ^ 2)                  ;; 거리 기반 가중치
        set funnel funnel + (avg-state * weight)   ;; 가중치 적용된 압력 합산
        set norm norm + weight                     ;; 가중치 합산
      ]
    ]
    set dist dist + 1  ;; 거리 증가
  ]

  ;; 정규화된 Funnel Pressure 반환
  ifelse norm = 0 [
    report 0  ;; 가중치 합산값이 0인 경우 압력 0으로 반환
  ] [
    report funnel / norm  ;; 정규화된 Funnel Pressure
  ]
end






to-report total-pressure
  let standing-ratio mean [ifelse-value standing? [1] [-1]] of turtles
  report standing-ratio
end






to calculate-awkwardness
  ask turtles [
    let standing-nbrs count my-neighbours with [standing?]
    let standing-ratio ifelse-value (n-of-neighbours > 0) [
      standing-nbrs / n-of-neighbours  ;; 이웃이 있는 경우 정상 계산
    ] [
      0  ;; 이웃이 없는 경우 standing-ratio를 0으로 설정
    ]
    set awkwardness abs(standing-ratio - ifelse-value (standing?) [1] [0])
  ]
end




;;;;;;;;;;;;;;;;;;;;;;
;;; MAIN PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;

to go
  ;; 정부 정당성 감소
  if external-pressure < 1 [  ;; 0 이하로 내려가지 않도록 제한
    set external-pressure external-pressure + 0.001
  ]

  if ticks mod 10 = 0 [
    set external-pressure external-pressure + 0.01
  ]

  ;; Tick에 따라 use-pressure 조정
  ifelse ticks <= 10 [
    set use-pressure false
  ] [
    set use-pressure true
  ]

  ;; 10 tick 이후 조건 확인
  let cost 0
  if ticks > 10 and use-pressure [
    let n-standing count turtles with [shape = "triangle" and standing?]
    let standing-ratio count turtles with [shape = "triangle" and standing?] / 108.0

    set cost w-cost * ((n-standing - 3.5) ^ 2 / 12.25 + epsilon)

    ask turtles [
      set P (external-pressure * belief) - cost
      if use-pressure [
        let funnel-p funnel-pressure self
        let total-p total-pressure
        let neighbor-p neighbor-pressure self
        set pressure exp((peer-w * (neighbor-p + funnel-p)) + (total-w * total-p))
        set P P + pressure
      ]
    ]

    if standing-ratio > (8 / 108) [
      user-message "이탈 당원들이 많아질 것 같습니다"
      stop
    ]
  ]

  if updating = "sync" [
    ask turtles [
      set P (external-pressure * belief) - cost
      if use-pressure [
        let funnel-p funnel-pressure self
        let total-p total-pressure
        let neighbor-p neighbor-pressure self
        set pressure exp((peer-w * (neighbor-p + funnel-p)) + (total-w * total-p))
        set P P + pressure
      ]

      ;; ✅ 여기서 개별 Turtle 문맥에서 실행하도록 수정
      ifelse P > threshold [
        set standing? true
        set shape "triangle"
        set color red
      ] [
        set standing? false
        set shape "circle"
        set color gray
      ]
    ]
  ]

  if updating = "async-rd" [
    ask n-of count turtles turtles with [shape = "circle" or shape = "triangle"] [
      set P (external-pressure * belief) - cost
      if use-pressure [
        let funnel-p funnel-pressure self
        let total-p total-pressure
        let neighbor-p neighbor-pressure self
        set pressure exp((peer-w * (neighbor-p + funnel-p)) + (total-w * total-p))
        set P P + pressure
      ]

      ;; ✅ Turtle 문맥에서 실행되도록 조정
      ifelse P > threshold [
        set standing? true
        set shape "triangle"
        set color red
      ] [
        set standing? false
        set shape "circle"
        set color gray
      ]
    ]
  ]

  if updating = "incentive" [
    incentive-based-updating
  ]

  tick
  do-graphs
end



to go-once
  let cost 0
  let n-standing count turtles with [shape = "triangle" and standing?]

  if use-pressure [
    ask turtles [
      set P (external-pressure * belief) - cost
      if use-pressure [
        let funnel-p funnel-pressure self
        let total-p total-pressure
        let neighbor-p neighbor-pressure self
        set pressure exp((peer-w * (neighbor-p + funnel-p)) + (total-w * total-p))
        set P P + pressure
      ]

      ifelse P > threshold [
        set standing? true
        set shape "triangle"
        set color red
      ] [
        set standing? false
        set shape "circle"
        set color gray
      ]
    ]
  ]

  tick  ;; ✅ tick이 observer 컨텍스트에서 실행되도록 수정
  do-graphs
end



to incentive-based-updating
  calculate-awkwardness

  let cost 0
  let n-standing count turtles with [shape = "triangle" and standing?]
  set cost w-cost * ((n-standing - 3.5) ^ 2 / 12.25 + epsilon)

  let sorted-turtles sort-on [awkwardness] turtles

  foreach reverse sorted-turtles [ [t] ->
    ask t [
      set P (external-pressure * belief) - cost
      if use-pressure [
        let funnel-p funnel-pressure self
        let total-p total-pressure
        let neighbor-p neighbor-pressure self
        set pressure exp((peer-w * (neighbor-p + funnel-p)) + (total-w * total-p))
        set P P + pressure
      ]

      ;; ✅ Turtle 문맥에서 실행되도록 조정
      ifelse P > threshold [
        set standing? true
        set shape "triangle"
        set color red
      ] [
        set standing? false
        set shape "circle"
        set color gray
      ]
    ]
  ]
end




;;;;;;;;;;;;;;;
;;; GRAPHS ;;;
;;;;;;;;;;;;;;;

to do-graphs
  ;; 동그라미 에이전트 상태 색상 업데이트
  ask turtles with [shape = "triangle" and standing?] [
    set color red
  ]
  ask turtles with [shape = "circle" and not standing?] [
    set color gray
  ]

  ;; awkward 상태 색상 업데이트
  ask turtles with [awkwardness > 0] [
    set color yellow
  ]

  ;; 그래프 업데이트
  do-plots
end



to do-plots
  set-current-plot "People"

  ;; 플롯 확인 및 각 펜 설정
  set-current-plot-pen "triangle-standing"
  plot count turtles with [shape = "triangle" and standing?]

  set-current-plot-pen "circle-sitting"
  plot count turtles with [shape = "circle" and not standing?]

  set-current-plot-pen "awkward"
  plot count turtles with [awkwardness > 0]
end



to show-vision
  if mouse-down? [
    ;; 마우스 클릭된 패치에 있는 에이전트를 기준으로 시야 강조
    ask patch mouse-xcor mouse-ycor [
      if any? turtles-here [
        ask one-of turtles-here [  ;; 해당 패치에 있는 하나의 거북이 선택
          let my-ycor ycor
          let my-xcor xcor

          ;; 현재 행의 좌우 하나씩 강조
          let left-patch patch (my-xcor - 1) my-ycor
          let right-patch patch (my-xcor + 1) my-ycor

          if any? turtles-on left-patch [
            ask left-patch [
              set pcolor green  ;; 서 있는 에이전트가 있으면 초록색
              if any? turtles-here with [not standing?] [set pcolor red]  ;; 앉아 있는 에이전트가 있으면 빨간색
            ]
          ]
          if any? turtles-on right-patch [
            ask right-patch [
              set pcolor green
              if any? turtles-here with [not standing?] [set pcolor red]
            ]
          ]

          ;; 상위 행 강조
          let dist 1
          while [dist <= cone-length] [
            let row-patches patches with [pycor = my-ycor + dist]
            let relevant-patches row-patches with [abs(pxcor - my-xcor) <= dist]
            ask relevant-patches [
              if any? turtles-here with [standing?] [
                set pcolor green  ;; 서 있는 에이전트가 있으면 초록색
              ]
              if any? turtles-here with [not standing?] [
                set pcolor red  ;; 앉아 있는 에이전트가 있으면 빨간색
              ]
            ]
            set dist dist + 1
          ]
        ]
      ]
    ]
  ]
  display
end
@#$#@#$#@
GRAPHICS-WINDOW
520
225
848
554
-1
-1
16.0
1
10
1
1
1
0
0
0
1
0
19
0
19
1
1
1
ticks
30.0

CHOOSER
9
94
158
139
updating
updating
"async-rd" "sync" "incentive"
0

BUTTON
652
165
730
198
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

TEXTBOX
9
11
159
29
Neighbourhood
12
0.0
1

TEXTBOX
10
75
160
93
Updating
12
0.0
1

PLOT
523
10
1790
160
People
tick
#people
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"triangle-standing" 1.0 0 -2674135 true "" "plot count turtles with [shape = \"triangle\" and standing?]"
"circle-sitting" 1.0 0 -7500403 true "" "plot count turtles with [shape = \"circle\" and not standing?]"
"awkward" 1.0 0 -1184463 true "" "plot count turtles with [awkwardness > 0]"

BUTTON
316
16
464
49
Show guy's vision
with-local-randomness [show-vision]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
317
55
381
88
clear
with-local-randomness [\n  ask patches [set pcolor black]\n]
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
137
34
195
67
apply
with-local-randomness [\n  ask turtles [setup-neighbourhood]\n]
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
553
165
647
198
go once
go-once
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
8
33
130
66
cone-length
cone-length
1
20
5.0
1
1
NIL
HORIZONTAL

TEXTBOX
12
149
55
167
Noise
12
0.0
1

BUTTON
7
214
74
247
NIL
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

SLIDER
0
256
172
289
total-w
total-w
0
1
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
0
414
172
447
w-cost
w-cost
0
1
0.1
0.01
1
NIL
HORIZONTAL

SWITCH
3
375
143
408
use-pressure
use-pressure
0
1
-1000

SLIDER
41
490
241
523
external-pressure
external-pressure
0
1
0.2
0.1
1
NIL
HORIZONTAL

SLIDER
1
292
173
325
peer-w
peer-w
0
1
1.0
0.01
1
NIL
HORIZONTAL

@#$#@#$#@
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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="new 당론 압박" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <exitCondition>(ticks &gt; 10 and count turtles with [shape = "triangle" and standing?] &gt;= 8)</exitCondition>
    <metric>count turtles with [shape = "triangle" and standing?]</metric>
    <metric>count turtles with [shape = "circle" and not standing?]</metric>
    <metric>mean [belief] of turtles with [shape = "triangle" and standing?]</metric>
    <metric>mean [belief] of turtles with [shape = "circle" and not standing?]</metric>
    <metric>mean [belief] of turtles</metric>
    <metric>mean [belief * external-pressure] of turtles</metric>
    <metric>mean [belief * external-pressure] of turtles with [shape = "triangle" and standing?]</metric>
    <metric>mean [belief * external-pressure] of turtles with [shape = "circle" and not standing?]</metric>
    <metric>mean [pressure] of turtles with [shape = "triangle" and standing?]</metric>
    <metric>mean [pressure] of turtles with [shape = "circle" and not standing?]</metric>
    <metric>mean [pressure] of turtles</metric>
    <metric>mean [(peer-w * (neighbor-pressure self + funnel-pressure self))] of turtles with [shape = "triangle" and standing?]</metric>
    <metric>mean [(peer-w * (neighbor-pressure self + funnel-pressure self))] of turtles with [shape = "circle" and not standing?]</metric>
    <metric>mean [(peer-w * (neighbor-pressure self + funnel-pressure self))] of turtles</metric>
    <metric>total-w * total-pressure</metric>
    <metric>mean [n-of-neighbours] of turtles with [shape = "triangle" and standing?]</metric>
    <metric>mean [n-of-neighbours] of turtles with [shape = "circle" and not standing?]</metric>
    <metric>mean [n-of-neighbours] of turtles</metric>
    <metric>w-cost * ((abs(count turtles with [shape = "triangle" and standing?] - 3.5)) ^ 2 / 12.25 + epsilon)</metric>
    <metric>mean [P] of turtles</metric>
    <metric>mean [P] of turtles with [shape = "triangle" and standing?]</metric>
    <metric>mean [P] of turtles with [shape = "circle" and not standing?]</metric>
    <enumeratedValueSet variable="updating">
      <value value="&quot;async-rd&quot;"/>
      <value value="&quot;sync&quot;"/>
      <value value="&quot;incentive&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-w">
      <value value="0.8"/>
      <value value="0.9"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="peer-w">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-pressure">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="w-cost">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cone-length">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="external-pressure">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="new 이웃 동조 효과" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <exitCondition>(ticks &gt; 10 and count turtles with [shape = "triangle" and standing?] &gt;= 8)</exitCondition>
    <metric>count turtles with [shape = "triangle" and standing?]</metric>
    <metric>count turtles with [shape = "circle" and not standing?]</metric>
    <metric>mean [belief] of turtles with [shape = "triangle" and standing?]</metric>
    <metric>mean [belief] of turtles with [shape = "circle" and not standing?]</metric>
    <metric>mean [belief] of turtles</metric>
    <metric>mean [belief * external-pressure] of turtles</metric>
    <metric>mean [belief * external-pressure] of turtles with [shape = "triangle" and standing?]</metric>
    <metric>mean [belief * external-pressure] of turtles with [shape = "circle" and not standing?]</metric>
    <metric>mean [pressure] of turtles with [shape = "triangle" and standing?]</metric>
    <metric>mean [pressure] of turtles with [shape = "circle" and not standing?]</metric>
    <metric>mean [pressure] of turtles</metric>
    <metric>mean [(peer-w * (neighbor-pressure self + funnel-pressure self))] of turtles with [shape = "triangle" and standing?]</metric>
    <metric>mean [(peer-w * (neighbor-pressure self + funnel-pressure self))] of turtles with [shape = "circle" and not standing?]</metric>
    <metric>mean [(peer-w * (neighbor-pressure self + funnel-pressure self))] of turtles</metric>
    <metric>total-w * total-pressure</metric>
    <metric>mean [n-of-neighbours] of turtles with [shape = "triangle" and standing?]</metric>
    <metric>mean [n-of-neighbours] of turtles with [shape = "circle" and not standing?]</metric>
    <metric>mean [n-of-neighbours] of turtles</metric>
    <metric>w-cost * ((abs(count turtles with [shape = "triangle" and standing?] - 3.5)) ^ 2 / 12.25 + epsilon)</metric>
    <metric>mean [P] of turtles</metric>
    <metric>mean [P] of turtles with [shape = "triangle" and standing?]</metric>
    <metric>mean [P] of turtles with [shape = "circle" and not standing?]</metric>
    <enumeratedValueSet variable="updating">
      <value value="&quot;async-rd&quot;"/>
      <value value="&quot;sync&quot;"/>
      <value value="&quot;incentive&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-w">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="peer-w">
      <value value="0.8"/>
      <value value="0.9"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-pressure">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="w-cost">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cone-length">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="external-pressure">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="new 외부 압력 증가" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <exitCondition>(ticks &gt; 10 and count turtles with [shape = "triangle" and standing?] &gt;= 8)</exitCondition>
    <metric>count turtles with [shape = "triangle" and standing?]</metric>
    <metric>count turtles with [shape = "circle" and not standing?]</metric>
    <metric>mean [belief] of turtles with [shape = "triangle" and standing?]</metric>
    <metric>mean [belief] of turtles with [shape = "circle" and not standing?]</metric>
    <metric>mean [belief] of turtles</metric>
    <metric>mean [belief * external-pressure] of turtles</metric>
    <metric>mean [belief * external-pressure] of turtles with [shape = "triangle" and standing?]</metric>
    <metric>mean [belief * external-pressure] of turtles with [shape = "circle" and not standing?]</metric>
    <metric>mean [pressure] of turtles with [shape = "triangle" and standing?]</metric>
    <metric>mean [pressure] of turtles with [shape = "circle" and not standing?]</metric>
    <metric>mean [pressure] of turtles</metric>
    <metric>mean [(peer-w * (neighbor-pressure self + funnel-pressure self))] of turtles with [shape = "triangle" and standing?]</metric>
    <metric>mean [(peer-w * (neighbor-pressure self + funnel-pressure self))] of turtles with [shape = "circle" and not standing?]</metric>
    <metric>mean [(peer-w * (neighbor-pressure self + funnel-pressure self))] of turtles</metric>
    <metric>total-w * total-pressure</metric>
    <metric>mean [n-of-neighbours] of turtles with [shape = "triangle" and standing?]</metric>
    <metric>mean [n-of-neighbours] of turtles with [shape = "circle" and not standing?]</metric>
    <metric>mean [n-of-neighbours] of turtles</metric>
    <metric>w-cost * ((abs(count turtles with [shape = "triangle" and standing?] - 3.5)) ^ 2 / 12.25 + epsilon)</metric>
    <metric>mean [P] of turtles</metric>
    <metric>mean [P] of turtles with [shape = "triangle" and standing?]</metric>
    <metric>mean [P] of turtles with [shape = "circle" and not standing?]</metric>
    <metric>external-pressure</metric>
    <enumeratedValueSet variable="updating">
      <value value="&quot;async-rd&quot;"/>
      <value value="&quot;sync&quot;"/>
      <value value="&quot;incentive&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-w">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="peer-w">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-pressure">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="w-cost">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cone-length">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="external-pressure">
      <value value="0.1"/>
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
