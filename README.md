# arabic-icr

## Content
This project contains all the artifacts from my M.Sc. research on online Arabic handwriting recognition carried out under the supervision of Dr. Rais Saabne and Prof. Dana Ron at the Tel-Aviv University.

## How to cite this work:

The bibtex entry for citing this work:

```
@phdthesis{kour2014real,
  title={Real-time Segmentation and Recognition of On-line Handwritten Arabic Script},
  author={Kour, George},
  year={2014},
  school={TEL AVIV UNIVERSITY}
}
```

## Abstract

Despite the long-standing belief that digital computers will challenge the future of handwriting, pen and paper remain commonly used means for communication and recording of information in daily life.
In addition to the growing use of keyboard-less devices such as smart-phones and tablets, which are too small to have a convenient keyboard, handwriting recognition is receiving increasing attention in the last decades.

Correct and efficient recognition of handwritten Arabic text is a challenging problem due to the cursive and unconstrained nature of the Arabic script.
While real-time performance is necessary in applications involving on-line handwriting recognition, conventional approaches usually wait until the entire curve is traced out before starting the analysis, inevitably causing delays in the recognition process. 
This deferment prevents on-line recognition techniques from achieving high responsiveness demands expected from such systems, and from implementing advanced features of input typing, such as automatic word completion.

This work presents a real-time approach for segmenting and recognizing handwritten on-line Arabic script.
We demonstrate the feasibility of segmenting Arabic handwritten text during the course of writing.
The proposed segmentation approach is a recognition-based method that operates on the stroke level and nominates candidate segmentation points based on morphological features.
Using a fast Arabic character classifier, the system attaches a score to the sub-strokes induced by the candidate points, which captures the likelihood of the sub-stroke to represent a letter.
A candidate filtering followed by a segmentation selection process are activated when the entire stroke is available.

A nearest neighbours based character classifier that employs a linear-time embedding of the Earth Mover's Distance metric to a norm space is presented.
The transformation of the feature space vectors into the wavelet coefficient space facilitates accurate similarity measurement and sub-linear search methods.
We show that the resulting character segmentation and classification information can be used to significantly reduce the potential dictionary size and accelerate a holistic recognition process.

