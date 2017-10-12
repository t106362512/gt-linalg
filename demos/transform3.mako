## /* -*- javascript -*-

<%! draggable=True %>

<%inherit file="base.mako"/>

<%block name="title">2x2 Matrix Transformations</%block>

<%block name="extra_script">
    <script type="application/glsl" id="vertex-xyz">
    // Enable STPQ mapping
    #define POSITION_STPQ
    void getPosition(inout vec4 xyzw, inout vec4 stpq) {
        // Store XYZ per vertex in STPQ
        stpq = xyzw;
    }
    </script>

    <script type="application/glsl" id="fragment-clipping">
    // Enable STPQ mapping
    #define POSITION_STPQ
    vec4 getColor(vec4 rgba, inout vec4 stpq) {
        stpq = abs(stpq - vec4(2.2, 0.0, 0.0, 0.0));

        // Discard pixels outside of clip box
        if(stpq.x > 1.0 || stpq.y > 1.0 || stpq.z > 1.0)
            discard;

        return rgba;
    }
    </script>
</%block>

## */

function decodeQS() {
    var decode, match, pl, query, search;
    pl = /\+/g;
    search = /([^&=]+)=?([^&]*)/g;
    decode = function(s) {
        return decodeURIComponent(s.replace(pl, " "));
    };
    query = window.location.search.substring(1);
    var urlParams = {};
    while (match = search.exec(query)) {
        urlParams[decode(match[1])] = decode(match[2]);
    }
    return urlParams;
}
var paramsQS = decodeQS();

var image = new Image();
image.src = "img/" + (paramsQS.pic || "theo2.jpg");
image.addEventListener('load', function() {
    onLoaded();
});

var matrix = [1,0,0,1];
if(paramsQS.mat)
    matrix = paramsQS.mat.split(',').map(parseFloat)


function onLoaded() {

    var updateMatrix = function() {
        matrix = [1,0,0,1];
        for(var i = 0; i < numTransforms; ++i) {
            var mult = paramses[i].matrix;
            var a = mult[0]*matrix[0] + mult[1]*matrix[2];
            var b = mult[0]*matrix[1] + mult[1]*matrix[3];
            var c = mult[2]*matrix[0] + mult[3]*matrix[2];
            var d = mult[2]*matrix[1] + mult[3]*matrix[3];
            matrix = [a, b, c, d];
        }
        updateMatrixElt();
        updateVectorsElt();
    }

    var doScale = function(params) {
        params.rotate = 0.0;
        params.xshear = 0.0;
        params.yshear = 0.0;
        params.matrix = [params.xscale, 0, 0, params.yscale];
        updateMatrix();
    };
    var doXShear = function(params) {
        params.xscale = 1.0;
        params.yscale = 1.0;
        params.rotate = 0.0;
        params.yshear = 0.0;
        params.matrix = [1,params.xshear,0,1];
        updateMatrix();
    };
    var doYShear = function(params) {
        params.xscale = 1.0;
        params.yscale = 1.0;
        params.rotate = 0.0;
        params.xshear = 0.0;
        params.matrix = [1,0,params.yshear,1];
        updateMatrix();
    };
    var doRotate = function(params) {
        params.xscale = 1.0;
        params.yscale = 1.0;
        params.xshear = 0.0;
        params.yshear = 0.0;
        var r = params.rotate;
        var c = Math.cos(r);
        var s = Math.sin(r);
        params.matrix = [c, -s, s, c];
         updateMatrix();
   };

    var Params = function() {
        this.xscale = 1.0;
        this.yscale = 1.0;
        this.rotate = 0.0;
        this.xshear = 0.0;
        this.yshear = 0.0;
        this.matrix = [1,0,0,1];
    };

    var numTransforms = 3;
    var paramses = [];
    var gui = new dat.GUI();
    for(var i = 0; i < numTransforms; ++i) {
        (function(params) {
            var folder = gui.addFolder('Transform ' + (i+1));
            if(i == 0)
                folder.open();
            folder.add(params, 'xscale', -2, 2).step(0.05).onChange(function() {
                doScale(params);
            }).listen();
            folder.add(params, 'yscale', -2, 2).step(0.05).onChange(function() {
                doScale(params);
            }).listen();
            folder.add(params, 'rotate', -Math.PI, Math.PI).step(0.05)
                .onChange(function() {
                    doRotate(params);
                }).listen();
            folder.add(params, 'xshear', -2, 2).step(0.05).onChange(function() {
                doXShear(params);
            }).listen();
            folder.add(params, 'yshear', -2, 2).step(0.05).onChange(function() {
                doYShear(params);
            }).listen();
            paramses.push(params);
        })(new Params());
    }

    if(paramsQS.closed)
        gui.closed = true;

    var ortho = 10000;
    var mathbox = window.mathbox = mathBox({
        plugins: ['core'],
        camera: {
            near:    ortho / 4,
            far:     ortho * 4,
        },
    });
    if (mathbox.fallback) throw "WebGL not supported"
    var three = mathbox.three;
    three.renderer.setClearColor(new THREE.Color(0, 0, 0), 1);
    var camera = mathbox
        .camera({
            proxy:    true,
            position: [1.1, 0, ortho],
            lookAt:   [1.1, 0, 0],
            up:       [0, 1, 0],
            fov:      Math.atan(2/ortho) * 360 / π,
        });
    mathbox.set('focus', ortho);

    var gridOpacity = 0.25;

    var view1 = mathbox
        .cartesian({
            range: [[-10,10], [-10,10]],
            scale: [1, 1],
        });
    view1
        .axis({
            classes:  ['axes'],
            axis:     1,
            end:      true,
            width:    2,
            depth:    1,
            color:    'white',
            opacity:  0.6,
            zOrder:   1,
            zIndex:   1,
            size:     3,
        })
        .axis({
            classes:  ['axes'],
            axis:     2,
            end:      true,
            width:    2,
            depth:    1,
            color:    'white',
            opacity:  0.6,
            zOrder:   1,
            zIndex:   1,
            size:     3,
        })
        .grid({
            classes:  ['axes', 'grid'],
            axes:     [1, 2],
            width:    1,
            depth:    1,
            color:    'white',
            opacity:  gridOpacity,
            zOrder:   1,
            zIndex:   1,
        })
    ;

    view1
        .image({
            image: image,
        })
        .matrix({
            width:    2,
            height:   2,
            channels: 2,
            data:     [[[-10, -10], [10, -10]],
                       [[-10,  10], [10,  10]]],
        })
        .surface({
            color:  0xffffff,
            points: '<',
            map:    '<<',
            fill:   true,
            zOrder: 0,
        })
    ;

    var vector = [1, 3, 0];

    // Make the vectors draggable
    var draggable = new Draggable({
        view:        view1,
        points:      [vector],
        size:        20,
        hiliteIndex: 3,
        hiliteColor: [0, 1, 1, .75],
        hiliteSize:  20,
        onDrag:  function() { updateVectorsElt(); },
    });
    mathbox.select("#draggable-hilite").set({
        zTest:   true,
        zWrite:  true,
        zOrder:  2,
        opacity: .5,
    });

    // Labeled vector
    view1
        .array({
            channels: 3,
            width:    1,
            items:    2,
            data:     [[0, 0, 0], vector],
        })
        .vector({
            color:  "rgb(0,255,0)",
            end:    true,
            size:   4,
            width:  3,
            zIndex: 2,
        })
        .array({
            channels: 3,
            width:    1,
            expr: function(emit) {
                emit(vector[0]/2, vector[1]/2, vector[2]/2);
            },
        })
        .text({
            live:  false,
            width: 1,
            data:  ['x'],
        })
        .label({
            outline: 1,
            background: "black",
            color:   "rgb(0,255,0)",
            offset:  [0, 25],
            size:    15,
            zIndex:  3,
        })
    ;


    var view2 = mathbox
        .cartesian({
            range: [[-10,10], [-10,10]],
            scale: [1, 1, 1],
        })
        .transform({
            position: [22, 0, 0],
        });

    view2
        .axis({
            classes:  ['axes'],
            axis:     1,
            end:      true,
            width:    2,
            depth:    1,
            color:    'white',
            opacity:  0.6,
            zIndex:   1,
            zOrder:   1,
            size:     3,
        })
        .axis({
            classes:  ['axes'],
            axis:     2,
            end:      true,
            width:    2,
            depth:    1,
            color:    'white',
            opacity:  0.6,
            zIndex:   1,
            zOrder:   1,
            size:     3,
        })
        .grid({
            classes:  ['axes', 'grid'],
            axes:     [1, 2],
            width:    1,
            depth:    1,
            color:    'white',
            opacity:  gridOpacity,
            zIndex:   1,
            zOrder:   1,
        })
    ;

    var clipped = view2
        .shader({code: "#vertex-xyz"})
        .vertex({pass: "world"})
        .shader({code: "#fragment-clipping"})
        .fragment();

    var transformed = clipped
        .transform({}, {
            matrix: function() {
                return [matrix[0], matrix[1], 0, 0, matrix[2], matrix[3], 0, 0,
                        0, 0, 1, 0, 0, 0, 0, 1];
            },
        })
        .image({
            image: image,
        })
        .matrix({
            width:    2,
            height:   2,
            channels: 2,
            data:     [[[-10, -10], [10, -10]],
                       [[-10,  10], [10,  10]]],
        })
        .surface({
            color:  0xffffff,
            points: '<',
            map:    '<<',
            fill:   true,
            zOrder: 0,
        })
    ;

    // Labeled vector
    view2
        .transform({}, {
            matrix: function() {
                return [matrix[0], matrix[1], 0, 0, matrix[2], matrix[3], 0, 0,
                        0, 0, 1, 0, 0, 0, 0, 1];
            },
        })
        .array({
            channels: 3,
            width:    1,
            items:    2,
            data:     [[0, 0, 0], vector],
        })
        .vector({
            color:  "rgb(255,255,0)",
            end:    true,
            size:   4,
            width:  3,
            zIndex: 2,
        })
        .array({
            channels: 3,
            width:    1,
            expr: function(emit) {
                emit(vector[0]/2, vector[1]/2, vector[2]/2);
            },
        })
        .text({
            live:  false,
            width: 1,
            data:  ['b'],
        })
        .label({
            outline: 1,
            background: "black",
            color:   "rgb(255,255,0)",
            offset:  [0, 25],
            size:    15,
            zIndex:  3,
        })
    ;

    var div = document.getElementsByClassName("mathbox-overlays")[0];
    var label = self.label = document.createElement("div");
    label.className = "overlay-text";
    div.appendChild(label);

    label.innerHTML = '<span id="matrix-here"></span>'
        + '<span id="vectors-here"></span>';
    var matrixSpan = document.getElementById("matrix-here");
    var vectorSpan = document.getElementById("vectors-here");

    // Caption
    var updateMatrixElt = function() {
        katex.render(
            "A = \\begin{bmatrix} "
                + matrix[0].toFixed(2) + "&" + matrix[1].toFixed(2) + "\\\\"
                + matrix[2].toFixed(2) + "&" + matrix[3].toFixed(2)
                + "\\end{bmatrix}"
                + "\\qquad A\\color{#00ff00}{x} = \\color{#ffff00}{b}",
            matrixSpan);
    };
    updateMatrixElt();

    var updateVectorsElt = function() {
        var outVec = [
            matrix[0] * vector[0] + matrix[1] * vector[1],
            matrix[2] * vector[0] + matrix[3] * vector[1]
        ];

        katex.render(
            "\\qquad A\\color{#00ff00}{"
                + "\\begin{bmatrix}"
                + vector[0].toFixed(2) + "\\\\"
                + vector[1].toFixed(2)
                + "\\end{bmatrix}} = \\color{#ffff00}{"
                + "\\begin{bmatrix}"
                + outVec[0].toFixed(2) + "\\\\"
                + outVec[1].toFixed(2)
                + "\\end{bmatrix}}",
            vectorSpan);
    }
    updateVectorsElt();
}
