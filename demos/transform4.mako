## /* -*- javascript -*-

<%! draggable=True %>

<%inherit file="base.mako"/>

<%block name="title">A transformation in steps</%block>

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

var mathbox = window.mathbox = mathBox({
    plugins: ['core', 'controls', 'cursor'],
    controls: {
        klass: THREE.OrbitControls,
        parameters: {
            //target: new THREE.Vector3(1, 0, 0),
            noPan: true,
        }
    },
    mathbox: {
        inspect: false,
    },
});
if (mathbox.fallback) throw "WebGL not supported"
var three = mathbox.three;
three.renderer.setClearColor(new THREE.Color(0, 0, 0), 1);
var camera = mathbox
    .camera({
        proxy:    true,
        position: [0, 1, -2],
        up:       [0, 1, 0],
        lookAt:   [0, 0, 0],
    });
mathbox.set('focus', 1.5);

var ranges = 3;
var view0 = mathbox.cartesian({
    range: [[-ranges, ranges], [-ranges, ranges], [-ranges, ranges]],
    scale: [-1/3, 1/3, 1/3],
    rotation: [-π/2, 0, 0],
});

var setupView = function(view) {
    var axisOpacity = 0.6;
    view
        .axis({
            classes:  ['axes'],
            axis:     1,
            end:      true,
            width:    2,
            depth:    1,
            color:    'white',
            opacity:  0.75,
            zOrder:   1,
            zIndex:   1,
            size:     5,
        })
        .axis({
            classes:  ['axes'],
            axis:     2,
            end:      true,
            width:    2,
            depth:    1,
            color:    'white',
            opacity:  0.75,
            zOrder:   1,
            zIndex:   1,
            size:     5,
        })
        .axis({
            classes:  ['axes'],
            axis:     3,
            end:      true,
            width:    2,
            depth:    1,
            color:    'white',
            opacity:  0.75,
            zOrder:   1,
            zIndex:   1,
            size:     5,
        })
    view
        .array({
            channels: 3,
            width:    3,
            data:     [[ranges*1.04,0,0],
                       [0,ranges*1.04,0],
                       [0,0,ranges*1.04]],
            live:     false,
        })
        .text({
            live:     false,
            width:    3,
            data:     ['x', 'y', 'z']
        })
        .label({
            classes: ['axes'],
            outline: 1,
            color:   "white",
            background: "black",
            offset:  [0,0],
            size:    15
        })
        .area({
            axes:   [1, 2],
            rangeX: [-ranges, ranges],
            rangeY: [-ranges, ranges],
            width:  21,
            height: 21,
            live:   false,
        })
        .surface({
            color: "rgb(55, 126, 184)",
            lineX: true,
            lineY: true,
            fill:  false,
            opacity: 0.75,
        })
        .swizzle({
            order: "zxyw",
        })
        .surface({
            color: "rgb(77, 175, 74)",
            lineX: true,
            lineY: true,
            fill:  false,
            opacity: 0.75,
        })
    ;
}

var view = view0.transform({
    pass: 'eye',
    position: [-1, 0, 0],
});

setupView(view);

var view2 = view
    .transform({
        pass: 'eye',
        position: [1, 0, 0],
    });

setupView(view2);

var view3 = view
    .transform({
        pass: 'eye',
        position: [2, 0, 0],
    });

setupView(view3);

var vector;
if(paramsQS.v)
    vector = paramsQS.v.split(",").map(parseFloat);
else
    vector = [1, 2, 3];

// Labeled vectors
view
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
        data:  [paramsQS.composed ? 'x' : 'u'],
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

// Step two
view2
    .array({
        channels: 3,
        width:    1,
        items:    2,
        expr: function(emit) {
            emit(0, 0, 0);
            emit(vector[0], vector[1], -vector[2]);
        },
    })
    .vector({
        color:  "rgb(255,255,0)",
        end:    true,
        size:   4,
        width:  3,
        zIndex: 2,
    })
;

if(paramsQS.composed) {
    view2
        .array({
            channels: 3,
            width:    1,
            expr: function(emit) {
                emit(vector[0]/2, vector[1]/2, -vector[2]/2);
            },
        })
        .text({
            live:  false,
            width: 1,
            data:  ['U(x)'],
        })
        .label({
            outline: 1,
            background: "black",
            color:   "rgb(255,255,0)",
            offset:  [0, 25],
            size:    15,
            zIndex:  3,
        });
}

// Step three
view3
    .array({
        channels: 3,
        width:    1,
        items:    2,
        expr: function(emit) {
            emit(0, 0, 0);
            emit(0, vector[1], -vector[2]);
        },
    })
    .vector({
        color:  "rgb(255,255,255)",
        end:    true,
        size:   4,
        width:  3,
        zIndex: 2,
    })
    .array({
        channels: 3,
        width:    1,
        expr: function(emit) {
            emit(0, vector[1]/2, -vector[2]/2);
        },
    })
    .text({
        live:  false,
        width: 1,
        data:  [paramsQS.composed ? 'T(U(x))' : 'T(u)'],
    })
    .label({
        outline: 1,
        background: "black",
        color:   "rgb(255,255,255)",
        offset:  [0, 25],
        size:    15,
        zIndex:  3,
    })
;

// Captions
var updateCaption;
var div = document.getElementsByClassName("mathbox-overlays")[0];
var label = self.label = document.createElement("div");
label.className = "overlay-text";
div.appendChild(label);

if(paramsQS.composed) {
    label.innerHTML = '<span id="matrix1-here"></span><br><br>'
        + '<span id="matrix2-here"></span><br><br>'
        + '<span id="matrix3-here"></span>';
    ;
    var matrix1Span = document.getElementById("matrix1-here");
    var matrix2Span = document.getElementById("matrix2-here");
    var matrix3Span = document.getElementById("matrix3-here");

    var updateMatrixElt = function(span, mat, inVec, outVec, incol, outcol, funcname) {
        katex.render(
            funcname + " = \\begin{bmatrix} "
                + mat[0] + "&" + mat[1] + "&" + mat[2] + "\\\\"
                + mat[3] + "&" + mat[4] + "&" + mat[5] + "\\\\"
                + mat[6] + "&" + mat[7] + "&" + mat[8]
                + "\\end{bmatrix}"
                + "\\color{" + incol + "}{"
                + "\\begin{bmatrix}"
                + inVec[0].toFixed(2) + "\\\\"
                + inVec[1].toFixed(2) + "\\\\"
                + inVec[2].toFixed(2)
                + "\\end{bmatrix}} = \\color{" + outcol + "}{"
                + "\\begin{bmatrix}"
                + outVec[0].toFixed(2) + "\\\\"
                + outVec[1].toFixed(2) + "\\\\"
                + outVec[2].toFixed(2)
                + "\\end{bmatrix}}",
            span);
    };

    updateCaption = function() {
        var vec1 = [vector[0], vector[1], -vector[2]];
        var vec2 = [0, vector[1], -vector[2]];
        updateMatrixElt(
            matrix1Span, [1,0,0,0,1,0,0,0,-1], vector, vec1, "#00ff00", "#ffff00",
            "U(\\color{#00ff00}{x})");
        updateMatrixElt(
            matrix2Span, [0,0,0,0,1,0,0,0,1], vec1, vec2, "#ffff00", "#ffffff",
            "T(\\color{#ffff00}{U(x)})");
        updateMatrixElt(
            matrix3Span, [0,0,0,0,1,0,0,0,-1], vector, vec2, "#00ff00", "#ffffff",
            "T(U(\\color{#00ff00}{x}))");
    };

} else {
    label.innerHTML = 'Starting vector: <span id="vec1"></span>&nbsp;&nbsp;'
        + 'Reflect over ' + katex.renderToString("\\color{#377eb8}{xy}") + "-plane: "
        + '<span id="vec2"></span>&nbsp;&nbsp;'
        + "Project onto " + katex.renderToString("\\color{#4daf4a}{yz}") + "-plane: "
        + '<span id="vec3"></span>';
    ;
    var vec1Span = document.getElementById('vec1');
    var vec2Span = document.getElementById('vec2');
    var vec3Span = document.getElementById('vec3');

    var makeVector = function(vec, col, elt) {
        return katex.render(
            "\\color{" + col + "}{\\begin{bmatrix}"
                + vec[0].toFixed(2) + "\\\\"
                + vec[1].toFixed(2) + "\\\\"
                + vec[2].toFixed(2)
                + "\\end{bmatrix}}", elt);
    };

    updateCaption = function() {
        makeVector(vector, "#00ff00", vec1Span);
        makeVector([vector[0], vector[1], -vector[2]], "#ffff00", vec2Span);
        makeVector([0, vector[1], -vector[2]], "#ffffff", vec3Span);
    };
}

updateCaption();

// Make the vectors draggable
var draggable = new Draggable({
    view:        view,
    points:      [vector],
    size:        20,
    hiliteIndex: 3,
    hiliteColor: [0, 1, 1, .75],
    hiliteSize:  20,
    eyeMatrix:   view[0].controller.uniforms.transformMatrix.value,
    getMatrix: function(d) {
        return view0[0].controller.viewMatrix;
    },
    onDrag: updateCaption,
});

