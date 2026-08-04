#ifndef TLM_DUMMY_INITIATOR_H
#define TLM_DUMMY_INITIATOR_H

/**
 * @file tlm_dummy_initiator.h
 * @brief Dummy Initiator for Unbound TLM Sockets (PAD 骨架)
 */

#include <systemc>
#include <tlm>
#include <tlm_utils/simple_initiator_socket.h>

namespace ethernet_tlm {

/**
 * @class tlm_dummy_initiator
 * @brief 虚拟 Initiator，用于绑定未连接的 target socket，避免仿真报错
 */
class tlm_dummy_initiator : public sc_core::sc_module {
public:
    tlm_utils::simple_initiator_socket<tlm_dummy_initiator> socket;

    SC_CTOR(tlm_dummy_initiator)
        : socket("socket")
    {
        socket.register_nb_transport_bw(this, &tlm_dummy_initiator::nb_transport_bw);
        socket.register_invalidate_direct_mem_ptr(this, &tlm_dummy_initiator::invalidate_direct_mem_ptr);
    }

    tlm::tlm_sync_enum nb_transport_bw(tlm::tlm_generic_payload& trans,
                                       tlm::tlm_phase& phase,
                                       sc_core::sc_time& delay)
    {
        return tlm::TLM_ACCEPTED;
    }

    void invalidate_direct_mem_ptr(sc_dt::uint64 start_range,
                                   sc_dt::uint64 end_range)
    {
        // Do nothing
    }
};

} // namespace ethernet_tlm

#endif // TLM_DUMMY_INITIATOR_H
