import React from "react";
import { useContext } from "react";
import { AdminContext } from "../../context/AdminContext";
import { useEffect } from "react";
import { AppContext } from "../../context/AppContext";
import { assets } from "../../assets/assets";

const AllBookings = () => {
  const { aToken, bookings, getAllBookings, cancelBooking } =
    useContext(AdminContext);
  const { slotDateFormat, currencySymbol } = useContext(AppContext);

  useEffect(() => {
    if (aToken) {
      getAllBookings();
      console.log(bookings);
    }
  }, [aToken]);

  return (
    <div className="w-full max-w-6xl m-5">
      <p className="mb-3 text-lg font-medium">All Bookings</p>

      <div className="tm-card text-sm max-h-[80vh] overflow-y-scroll min-h-[60vh]">
        <div className="hidden sm:grid grid-cols-[0.5fr_3fr_2fr_3fr_3fr_1fr_1fr] grid-flow-col py-3 px-6 border-b border-gray-200">
          <p>#</p>
          <p>Client</p>
          <p>Phone</p>
          <p>Date & Time</p>
          <p>Expert</p>
          <p>Fees</p>
          <p>Action</p>
        </div>

        {bookings.map((item, index) => {
          return (
            <div
              className="flex flex-wrap justify-between max-sm:gap-2 sm:grid sm:grid-cols-[0.5fr_3fr_2fr_3fr_3fr_1fr_1fr] items-center text-gray-500 py-3 px-6 border-b border-gray-200 hover:bg-gray-50"
              key={index}
            >
              <p className="max-sm:hidden">{index + 1}</p>
              <div className="flex items-center gap-2">
                <img
                  className="w-8 h-8 object-cover rounded-full"
                  src={item.userData.image}
                  alt=""
                />
                <p>{item.userData.name}</p>
              </div>
              <p className="max-sm:hidden">{item.userData.phone}</p>
              <p>
                {slotDateFormat(item.slotDate)}, {item.slotTime}
              </p>
              <div className="flex items-center gap-2">
                <img
                  className="w-8 h-8 object-cover rounded-full"
                  src={item.cowData.image}
                  alt=""
                />
                <p>{item.cowData.name}</p>
              </div>

              <p>
                {item.amount} {currencySymbol}
              </p>
              {item.cancelled ? (
                <p className="text-red-500 text-xs font-medium">Cancelled</p>
              ) : (
                <img
                  onClick={() => cancelBooking(item._id)}
                  className="w-10 cursor-pointer"
                  src={assets.cancel_icon}
                  alt=""
                />
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
};

export default AllBookings;
