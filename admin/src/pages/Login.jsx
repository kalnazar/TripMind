import React, { useContext, useState } from "react";
import { assets } from "../assets/assets";
import { AdminContext } from "../context/AdminContext";
import axios from "axios";
import { toast } from "react-toastify";
import { ExpertContext } from "../context/ExpertContext";

const Login = () => {
  const [role, setRole] = useState("Admin");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const { setAToken, backendUrl } = useContext(AdminContext);
  const { setEToken } = useContext(ExpertContext);

  const onSubmitHandler = async (event) => {
    event.preventDefault();
    try {
      const { data } = await axios.post(backendUrl + "/api/auth/login", {
        email,
        password,
      });

      const token = data?.token;
      if (!token) {
        toast.error("Login failed");
        return;
      }

      if (role === "Admin") {
        // Validate token is actually admin by calling an admin-only endpoint
        await axios.get(backendUrl + "/api/admin/dashboard", {
          headers: { Authorization: `Bearer ${token}` },
        });

        localStorage.setItem("aToken", token);
        setAToken(token);
      } else {
        // Validate token is actually expert
        await axios.get(backendUrl + "/api/experts/me", {
          headers: { Authorization: `Bearer ${token}` },
        });

        localStorage.setItem("eToken", token);
        setEToken(token);
      }
    } catch (error) {
      toast.error(
        error?.response?.data?.message || "Invalid credentials or wrong role",
      );
    }
  };

  return (
    <form
      onSubmit={onSubmitHandler}
      className="min-h-screen flex items-center justify-center px-4 py-16"
    >
      <div className="tm-card relative w-full max-w-md p-8 sm:p-10 text-slate-700">
        <div className="absolute -top-10 -right-10 h-28 w-28 rounded-full bg-primary/10 blur-2xl" />
        <div className="absolute -bottom-12 -left-12 h-32 w-32 rounded-full bg-indigo-300/20 blur-3xl" />

        <div className="relative z-10 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <img className="h-10 w-10" src={assets.admin_logo} alt="TripMind" />
            <div>
              <p className="text-lg font-semibold text-slate-900">
                Trip<span className="text-primary">Mind</span> Console
              </p>
              <p className="text-xs text-slate-500">
                Secure access to your workspace
              </p>
            </div>
          </div>
          <span className="tm-chip">{role}</span>
        </div>

        <div className="relative z-10 mt-6 space-y-4">
          <div>
            <p className="text-sm font-medium text-slate-600">Email</p>
            <input
              onChange={(e) => setEmail(e.target.value)}
              value={email}
              className="tm-input mt-2"
              type="email"
              placeholder="admin@tripmind.com"
              required
            />
          </div>
          <div>
            <p className="text-sm font-medium text-slate-600">Password</p>
            <input
              onChange={(e) => setPassword(e.target.value)}
              value={password}
              className="tm-input mt-2"
              type="password"
              placeholder="••••••••"
              required
            />
          </div>

          <button className="tm-button w-full text-base">Login</button>
        </div>

        <div className="relative z-10 mt-4 text-sm text-slate-600">
          {role === "Admin" ? (
            <p>
              Expert Login?{" "}
              <span
                onClick={() => setRole("Expert")}
                className="cursor-pointer font-semibold text-primary"
              >
                Switch to Expert
              </span>
            </p>
          ) : (
            <p>
              Admin Login?{" "}
              <span
                onClick={() => setRole("Admin")}
                className="cursor-pointer font-semibold text-primary"
              >
                Switch to Admin
              </span>
            </p>
          )}
        </div>
      </div>
    </form>
  );
};

export default Login;
