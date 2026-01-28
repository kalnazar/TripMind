import { useState } from "react";
import { createContext } from "react";
import axios from "axios";
import { toast } from "react-toastify";

export const ExpertContext = createContext();

const ExpertContextProvider = (props) => {
  const backendUrl = import.meta.env.VITE_BACKEND_URL;
  const [eToken, setEToken] = useState(
    localStorage.getItem("eToken") ? localStorage.getItem("eToken") : ""
  );
  const [profileData, setProfileData] = useState(null);
  const [bookings, setBookings] = useState([]);

  const authHeaders = () => ({
    Authorization: `Bearer ${eToken}`,
  });

  const getProfileData = async () => {
    try {
      const { data } = await axios.get(backendUrl + "/api/experts/me", {
        headers: authHeaders(),
      });
      setProfileData(data);
    } catch (error) {
      toast.error(error?.response?.data?.message || error.message);
    }
  };

  const updateProfile = async (payload) => {
    try {
      const { data } = await axios.patch(
        backendUrl + "/api/experts/me",
        payload,
        { headers: authHeaders() }
      );
      setProfileData(data);
      toast.success("Profile updated");
      return data;
    } catch (error) {
      toast.error(error?.response?.data?.message || error.message);
      throw error;
    }
  };

  const getBookings = async () => {
    try {
      const { data } = await axios.get(backendUrl + "/api/experts/bookings", {
        headers: authHeaders(),
      });
      setBookings(data);
    } catch (error) {
      toast.error(error?.response?.data?.message || error.message);
    }
  };

  const updateBookingStatus = async (id, status) => {
    try {
      const { data } = await axios.patch(
        backendUrl + `/api/experts/bookings/${id}`,
        { status },
        { headers: authHeaders() }
      );
      setBookings((prev) =>
        prev.map((booking) => (booking.id === id ? data : booking))
      );
      toast.success(`Booking ${status.toLowerCase()}`);
      return data;
    } catch (error) {
      toast.error(error?.response?.data?.message || error.message);
      throw error;
    }
  };

  const value = {
    eToken,
    setEToken,
    backendUrl,
    getProfileData,
    updateProfile,
    profileData,
    setProfileData,
    bookings,
    getBookings,
    updateBookingStatus,
  };

  return (
    <ExpertContext.Provider value={value}>
      {props.children}
    </ExpertContext.Provider>
  );
};

export default ExpertContextProvider;
