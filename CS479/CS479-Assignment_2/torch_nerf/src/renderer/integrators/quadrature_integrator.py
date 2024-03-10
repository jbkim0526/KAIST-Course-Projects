"""
Integrator implementing quadrature rule.
"""

from typing import Tuple
from typeguard import typechecked

from jaxtyping import Float, jaxtyped
import torch
from torch_nerf.src.renderer.integrators.integrator_base import IntegratorBase


class QuadratureIntegrator(IntegratorBase):
    """
    Numerical integrator which approximates integral using quadrature.
    """

    @jaxtyped
    @typechecked
    def integrate_along_rays(
        self,
        sigma: Float[torch.Tensor, "num_ray num_sample"],
        radiance: Float[torch.Tensor, "num_ray num_sample 3"],
        delta: Float[torch.Tensor, "num_ray num_sample"],
    ) -> Tuple[Float[torch.Tensor, "num_ray 3"], Float[torch.Tensor, "num_ray num_sample"]]:
        """
        Computes quadrature rule to approximate integral involving in volume rendering.
        Pixel colors are computed as weighted sums of radiance values collected along rays.

        For details on the quadrature rule, refer to 'Optical models for
        direct volume rendering (IEEE Transactions on Visualization and Computer Graphics 1995)'.

        Args:
            sigma: Density values sampled along rays.
            radiance: Radiance values sampled along rays.
            delta: Distance between adjacent samples along rays.

        Returns:
            rgbs: Pixel colors computed by evaluating the volume rendering equation.
            weights: Weights used to determine the contribution of each sample to the final pixel color.
                A weight at a sample point is defined as a product of transmittance and opacity,
                where opacity (alpha) is defined as 1 - exp(-sigma * delta).
        """
        # TODO
        # HINT: Look up the documentation of 'torch.cumsum'.
        num_ray, num_sample = sigma.shape 
        device = sigma.device
        mul_t = -sigma*delta
        zeros = torch.zeros(num_ray,1, device=device)
        accum_trans = torch.exp(torch.cat((zeros,torch.cumsum(mul_t, dim = 1)),dim = 1)[...,:-1]).unsqueeze(-1).expand(num_ray,num_sample,3)
        weights = 1 - torch.exp(mul_t)
        expanded_weights = weights.unsqueeze(-1).expand(num_ray,num_sample,3)
        rgbs = torch.sum(accum_trans * expanded_weights * radiance, dim= 1)
        return rgbs, weights
