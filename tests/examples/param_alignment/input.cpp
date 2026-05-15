/**
 * @brief Compute a weighted average.
 * @param values input data
 * @param weights per-element weights, same length as values
 * @param tolerance ignored if weights sum to zero
 */
double weighted_mean(const double* values,
                     const double* weights,
                     double tolerance);
