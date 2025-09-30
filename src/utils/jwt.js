import jwt from "jsonwebtoken";

/**
 * Verify a JWT and return its payload.
 * @param {string} token - The JWT token string
 * @returns {Object} - Decoded payload
 * @throws {Error} - If invalid or expired
 */
export function verifyJwt(token) {
  try {
    return jwt.verify(token, process.env.JWT_PRIVATE_KEY, {
      algorithms: [process.env.JWT_KEY_ALGO || "HS256"],
    });
  } catch (err) {
    throw new Error("Invalid or expired token");
  }
}