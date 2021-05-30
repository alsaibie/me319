@def title = "Prelab 6"
@def hascode = true
# Prelab 6: Offline Digital Filtering

In this prelab we will review the process of analyzing a noisy signal, designing digital filters and implementing them as difference equations.
Let's first create a noisy signal by combining  sinusoidal signals of different amplitudes and frequencies, and adding random noise to it.

~~~
<iframe src="https://player.vimeo.com/video/556846322" width="640" height="360" frameborder="0" allowfullscreen></iframe>
~~~
\input{matlab}{/prelabs/pl6assets/snippet1.m}
<!-- Output:
\input{plaintext}{/prelabs/pl6assets/snippet1.out} -->
\fig{/prelabs/pl6assets/snippet1}

Let's decompose the signal and look at its frequency spectrum by using an FFT (Fast Fourier Transform). We want to observe the strength of the of each frequency component

\input{matlab}{/prelabs/pl6assets/snippet2.m}
<!-- Output:
\input{plaintext}{/prelabs/pl6assets/snippet2.out} -->
\fig{/prelabs/pl6assets/snippet2}

We can see that we have three main frequency components, as expected, the other ripple is due to the random noise we added. Let's apply a first order filter first and see if we can remove the noise and higher frequency components. 

### Simple First Order Filter 
A simple first order low pass filter takes the Laplace form

$$
F(s) = \dfrac{1}{1+s\omega_c}
$$

And in the discrete Z-domain

$$
F(z^{-1}) = \dfrac{(1-\alpha)z^{-1}}{1-\alpha z^{-1}}
$$

It is implemented in a digital form as a difference equation

$$
y[k] = (1-\alpha) x[k-1]+\alpha y[k-1]
$$

where $\alpha=e^{-2\pi \omega_c T_s} $

### Bode Plots
Bode plots are a useful tool for assessing the performance of a signal filter. They are composed of a magnitude and phase diagram. The magnitude diagram gives us the magnitude ratio (gain) between the output and input of the filter at a range of frequencies. While the phase diagram gives us the phase shift of the output signal compared to the input signal.

We can convert our filter parameters into transfer functions using the TransferFunction command from scipy.signal, then call the bode function from within the transfer function object.

\input{matlab}{/prelabs/pl6assets/snippet3.m}
Output:
\input{plaintext}{/prelabs/pl6assets/snippet3.out}
\fig{/prelabs/pl6assets/snippet3}

## Butterworth Filter
Now let's try to apply a butterworth filter instead.

Butterworth_filter

"The Butterworth filter is a type of signal processing filter designed to have a frequency response as flat as possible in the passband" 

In other words, the Butterworth filter will attempt to retain more of the signal strength (amplitude) in the frequency region desired. Here we chose to use a 2nd order Butterworth filter. It's transfer function in the z-domain is

$$
F(z^{-1}) = \dfrac{b_2 + b_1 z^{-1} b_0 z^{-2} }{1-a_1 z^{-1} - a_2 z^{-2}}
$$

which gives the difference equation

$$
y[k] = b_2 x[k] + b_1 x[k-1] + b_0 x[k-2] - a_1 y[k-1] - a_2 y[k-2]
$$

\input{matlab}{/prelabs/pl6assets/snippet4.m}
Output:
\input{plaintext}{/prelabs/pl6assets/snippet4.out}
\fig{/prelabs/pl6assets/snippet4}

The butterworth filter doesn't improve the phase delay much. Let's try a bessel filter 
\input{matlab}{/prelabs/pl6assets/snippet5.m}
\fig{/prelabs/pl6assets/snippet5}


We can see that a cut-off frequency of 100Hz is required to maintain a decent amplitude response. A a first order low pass filter produces the best phase reponse, and worst filtering. So it is a trade-off between good filtering vs. maintaining phase response. 
Let's try to apply a first order low pass filter to maintain a good phase response, but then add two notch filters to attack the higher frequency visible components at f = 4*5Hz, 16*5Hz
\input{matlab}{/prelabs/pl6assets/snippet6.m}
Output:
\input{plaintext}{/prelabs/pl6assets/snippet6.out}
<!-- \fig{/prelabs/pl6assets/snippet5} -->

\input{matlab}{/prelabs/pl6assets/snippet7.m}
<!-- Output: -->
<!-- \input{plaintext}{/prelabs/pl6assets/snippet7.out} -->
\fig{/prelabs/pl6assets/snippet7}

Let's compare the root-mean-square error for each of the different methods tried.
\input{matlab}{/prelabs/pl6assets/snippet8.m}
Output:
\input{plaintext}{/prelabs/pl6assets/snippet8.out}